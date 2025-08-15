import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/models/user.dart';
import 'package:sahiyar_club/utils/hive_database.dart';

class AuthenticationController extends GetxController {
  final User user = Get.arguments;
  final HiveDatabase _hiveDatabase = Get.find<HiveDatabase>();

  final TextEditingController pinController = TextEditingController();

  // Observable variables
  final RxBool isCheckingBiometrics = true.obs;
  final RxBool isAuthenticating = false.obs;
  final RxBool showPinSetup = false.obs;
  final RxBool showPinAuth = false.obs;
  final RxBool isConfirmingPin = false.obs;
  final RxString tempPin = ''.obs;
  final RxString pinError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthentication();
  }

  Future<void> _initializeAuthentication() async {
    isCheckingBiometrics.value = true;

    try {
      final biometrics = await availableBiometrics;

      if (biometrics.contains(BiometricType.strong) ||
          biometrics.contains(BiometricType.fingerprint) ||
          biometrics.contains(BiometricType.face)) {
        isCheckingBiometrics.value = false;
        authenticate();
      } else {
        // Check if PIN exists in database
        final existingPin = await _hiveDatabase.getString('user_pin');

        isCheckingBiometrics.value = false;

        if (existingPin == null) {
          // No PIN exists, show PIN setup
          showPinSetup.value = true;
        } else {
          // PIN exists, show PIN authentication
          showPinAuth.value = true;
        }
      }
    } catch (e) {
      print('Error initializing authentication: $e');
      isCheckingBiometrics.value = false;
      // Fallback to PIN
      final existingPin = await _hiveDatabase.getString('user_pin');
      if (existingPin == null) {
        showPinSetup.value = true;
      } else {
        showPinAuth.value = true;
      }
    }
  }

  Future<List<BiometricType>> get availableBiometrics async {
    final LocalAuthentication auth = LocalAuthentication();
    return await auth.getAvailableBiometrics();
  }

  void authenticate() async {
    isAuthenticating.value = true;
    pinError.value = '';

    try {
      final List<BiometricType> biometrics = await availableBiometrics;

      if (biometrics.contains(BiometricType.strong) ||
          biometrics.contains(BiometricType.fingerprint) ||
          biometrics.contains(BiometricType.face)) {
        final LocalAuthentication auth = LocalAuthentication();

        final result = await auth.authenticate(
          localizedReason: 'Please authenticate to start using the app',
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (result) {
          onSuccess();
        } else {
          pinError.value = 'Biometric authentication failed';
        }
      } else {
        pinError.value = 'No strong biometric authentication available';
      }
    } catch (e) {
      print('Authentication error: $e');
      pinError.value = 'Authentication error occurred';
    } finally {
      isAuthenticating.value = false;
    }
  }

  void _handlePinSetup() async {
    if (!isConfirmingPin.value) {
      if (_isValidPin(pinController.text)) {
        tempPin.value = pinController.text;
        pinController.text = '';
        isConfirmingPin.value = true;
        pinController.text = '';
        pinController.clear();
      } else {
        pinError.value = 'PIN must not contain repeated or sequential digits';
        pinController.text = '';
        pinController.clear();
      }
    } else {
      if (pinController.text == tempPin.value) {
        await _savePin(pinController.text);
        onSuccess();
      } else {
        pinError.value = 'PINs do not match. Please try again.';
        pinController.text = '';
        tempPin.value = '';
        isConfirmingPin.value = false;
        pinController.clear();
      }
    }
  }

  void _handlePinAuth() async {
    final savedPin = await _hiveDatabase.getString('user_pin');
    if (pinController.text == savedPin) {
      onSuccess();
    } else {
      pinError.value = 'Incorrect PIN. Please try again.';
      pinController.text = '';
      pinController.clear();
    }
  }

  bool _isValidPin(String pin) {
    return pin.length == 4 && RegExp(r'^\d{4}$').hasMatch(pin);
  }

  Future<void> _savePin(String pin) async {
    await _hiveDatabase.saveString('user_pin', pin);
  }

  void clearPin() {
    pinController.clear();
    pinError.value = '';
  }

  void onPinCompleted() {
    if (showPinSetup.value) {
      _handlePinSetup();
    } else if (showPinAuth.value) {
      _handlePinAuth();
    }
  }

  // create on pin changed
  void onPinChanged(String pin) {
    pinError.value = '';
  }

  void forgotPin() {
    Get.dialog(
      AlertDialog(
        title: const Text('Forgot PIN'),
        content: const Text(
          'Forgetting your PIN will log you out and and You will need to log in again.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _resetAuthentication();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAuthentication() async {
    // Remove PIN and token
    await _hiveDatabase.remove('user_pin');
    await _hiveDatabase.removeToken();
    await _hiveDatabase.removeUser();

    // Navigate to login
    Get.offAllNamed('/login');
  }

  void onSuccess() {
    Get.offAllNamed(AppRoutes.HOME, arguments: user);
  }
}

// Custom PIN Keypad Widget
class PinKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspace;

  const PinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Digits 1-3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                [
                  '1',
                  '2',
                  '3',
                ].map((digit) => _buildKey(context, digit)).toList(),
          ),
          const SizedBox(height: 16),
          // Digits 4-6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                [
                  '4',
                  '5',
                  '6',
                ].map((digit) => _buildKey(context, digit)).toList(),
          ),
          const SizedBox(height: 16),
          // Digits 7-9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                [
                  '7',
                  '8',
                  '9',
                ].map((digit) => _buildKey(context, digit)).toList(),
          ),
          const SizedBox(height: 16),
          // 0 and backspace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 70), // Empty space
              _buildKey(context, '0'),
              _buildBackspaceKey(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(BuildContext context, String digit) {
    return InkWell(
      onTap: () => onDigitPressed(digit),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            digit,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey(BuildContext context) {
    return InkWell(
      onTap: onBackspace,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
