import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sahiyar_club/controllers/otp_controller.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(context, controller),
            const SizedBox(height: 40),
            _buildOtpCard(context, controller),
            const SizedBox(height: 30),
            _buildVerifyButton(context, controller),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      title: Text(
        'OTP Verification',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Get.back(),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader(BuildContext context, OtpController controller) {
    return Column(
      children: [
        _buildIllustration(context),
        const SizedBox(height: 24),
        Text(
          'Verify Your Number',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a 6-digit code to',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '+91 ${controller.mobile}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.amber[700],
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[400]!, Colors.amber[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.smartphone_rounded,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildOtpCard(BuildContext context, OtpController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Enter OTP Code',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          _buildPinCodeField(context, controller),
        ],
      ),
    );
  }

  Widget _buildPinCodeField(BuildContext context, OtpController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PinCodeTextField(
      controller: controller.otpController,
      appContext: context,
      length: 6,
      keyboardType: TextInputType.number,
      animationType: AnimationType.slide,
      enableActiveFill: true,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],

      textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),

      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12),
        fieldHeight: 56,
        fieldWidth: 48,
        borderWidth: 2,

        // Active (currently typing)
        activeColor: Colors.amber[600]!,
        activeFillColor: Colors.amber.withOpacity(0.1),

        // Selected (focused but empty)
        selectedColor: Colors.amber[400]!,
        selectedFillColor: Colors.amber.withOpacity(0.05),

        // Inactive (empty, not focused)
        inactiveColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        inactiveFillColor:
            isDark
                ? Theme.of(context).colorScheme.surface
                : Colors.grey.withOpacity(0.05),

        // Error state
        errorBorderColor: Colors.red[400]!,
      ),

      onChanged: (value) {
        HapticFeedback.selectionClick();
      },

      onCompleted: (value) {
        HapticFeedback.lightImpact();
        controller.validateOtp(value);
      },
    );
  }

  Widget _buildVerifyButton(BuildContext context, OtpController controller) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final otpText = controller.otpController.text;
      final isValid = otpText.length == 6;

      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed:
              (isLoading || !isValid)
                  ? null
                  : () => controller.validateOtp(otpText),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[600],
            foregroundColor: Colors.white,
            disabledBackgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withOpacity(0.2),
            disabledForegroundColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(
                    'Verify & Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      );
    });
  }
}
