import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/forgot_password_controller.dart';
import 'package:sahiyar_club/widgets/custom_button.dart';
import 'package:sahiyar_club/widgets/custom_form_field.dart';

class ForgotPasswordModal extends StatelessWidget {
  const ForgotPasswordModal({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller = Get.put(
      ForgotPasswordController(),
    );

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Reset Password',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Enter your mobile number to receive OTP',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Obx(() {
            if (controller.currentStep.value ==
                ForgotPasswordStep.enterMobile) {
              return _buildMobileStep(controller, context);
            } else if (controller.currentStep.value ==
                ForgotPasswordStep.enterOtp) {
              return _buildOtpStep(controller, context);
            } else {
              return _buildNewPasswordStep(controller, context);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildMobileStep(
    ForgotPasswordController controller,
    BuildContext context,
  ) {
    return Column(
      children: [
        CustomFormField(
          controller: controller.mobileController,
          label: 'Mobile Number',
          keyboardType: TextInputType.phone,
          placeholder: "10-digit mobile number",
          maxLength: 10,
        ),
        const SizedBox(height: 20),
        Obx(
          () => CustomButton(
            label: 'Send OTP',
            onPressed: controller.sendOtp,
            isLoading: controller.isLoading.value,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(
    ForgotPasswordController controller,
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          'OTP sent to ${controller.mobileController.text}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        CustomFormField(
          controller: controller.otpController,
          label: 'OTP',
          keyboardType: TextInputType.number,
          placeholder: "Enter 6-digit OTP",
          maxLength: 6,
        ),
        const SizedBox(height: 20),

        Obx(
          () => CustomButton(
            label: 'Verify OTP',
            onPressed: controller.verifyOtp,
            isLoading: controller.isLoading.value,
          ),
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: () => controller.sendOtp(),
          child: const Text('Resend OTP'),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep(
    ForgotPasswordController controller,
    BuildContext context,
  ) {
    return Column(
      children: [
        CustomFormField(
          controller: controller.newPasswordController,
          label: 'New Password',
          placeholder: "Enter new password",
          obscureText: true,
        ),
        const SizedBox(height: 16),

        CustomFormField(
          controller: controller.confirmPasswordController,
          label: 'Confirm Password',
          placeholder: "Confirm new password",
          obscureText: true,
        ),
        const SizedBox(height: 20),

        Obx(
          () => CustomButton(
            label: 'Reset Password',
            onPressed: controller.resetPassword,
            isLoading: controller.isLoading.value,
          ),
        ),
      ],
    );
  }
}
