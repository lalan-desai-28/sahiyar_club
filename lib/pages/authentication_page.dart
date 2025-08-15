import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sahiyar_club/controllers/authentication_controller.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final AuthenticationController authenticationController =
      Get.find<AuthenticationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Obx(() {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Authentication Status
                if (authenticationController.isCheckingBiometrics.value)
                  _buildCheckingBiometricsWidget()
                else if (authenticationController.showPinSetup.value)
                  _buildPinSetupWidget()
                else if (authenticationController.showPinAuth.value)
                  _buildPinAuthWidget()
                else
                  _buildBiometricAuthWidget(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCheckingBiometricsWidget() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Checking available authentication methods...',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBiometricAuthWidget() {
    return Column(
      children: [
        Icon(
          Icons.lock,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Secure Authentication',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please authenticate to access the app',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                authenticationController.isAuthenticating.value
                    ? null
                    : () => authenticationController.authenticate(),
            icon:
                authenticationController.isAuthenticating.value
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.security),
            label: Text(
              authenticationController.isAuthenticating.value
                  ? 'Authenticating...'
                  : 'Authenticate',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinSetupWidget() {
    return Column(
      children: [
        Icon(Icons.pin, size: 80, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          authenticationController.isConfirmingPin.value
              ? 'Confirm Your PIN'
              : 'Create Security PIN',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          authenticationController.isConfirmingPin.value
              ? 'Please enter your PIN again to confirm'
              : 'Create a strong 4-digit PIN for secure access',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildPinCodeField(),
        const SizedBox(height: 24),
        if (authenticationController.pinError.value.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authenticationController.pinError.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPinAuthWidget() {
    return Column(
      children: [
        Icon(
          Icons.lock,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Enter Your PIN',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter your 4-digit security PIN',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildPinCodeField(),
        const SizedBox(height: 24),
        if (authenticationController.pinError.value.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authenticationController.pinError.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => authenticationController.forgotPin(),
          child: const Text('Forgot PIN?'),
        ),
      ],
    );
  }

  Widget _buildPinCodeField() {
    return SizedBox(
      width: 280,
      child: PinCodeTextField(
        backgroundColor: Colors.transparent,

        controller: authenticationController.pinController,
        appContext: context,
        length: 4,
        obscureText: true,
        obscuringCharacter: '●',
        blinkWhenObscuring: true,
        animationType: AnimationType.fade,
        validator: (value) => null,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(12),
          fieldHeight: 60,
          fieldWidth: 60,
          borderWidth: 2,
          activeBorderWidth: 2,
          selectedBorderWidth: 2,
          inactiveBorderWidth: 1,
          errorBorderWidth: 2,
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          selectedColor: Theme.of(context).colorScheme.primary,
          activeFillColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          inactiveFillColor: Theme.of(context).colorScheme.surface,
          selectedFillColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          errorBorderColor: Colors.red,
        ),
        cursorColor: Theme.of(context).colorScheme.primary,
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        keyboardType: TextInputType.number,

        onCompleted: (value) => authenticationController.onPinCompleted(),
        onSubmitted: (value) => authenticationController.onPinCompleted(),
        beforeTextPaste: (text) {
          return text?.length == 4 && RegExp(r'^\d+$').hasMatch(text ?? '');
        },
        obscuringWidget: Container(
          alignment: Alignment.center,
          child: Text(
            '●',
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),

        onEditingComplete: () {
          authenticationController.onPinCompleted();
        },
      ),
    );
  }
}
