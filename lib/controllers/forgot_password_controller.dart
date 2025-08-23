import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/repositories/users_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

enum ForgotPasswordStep { enterMobile, enterOtp, enterNewPassword }

class ForgotPasswordController extends GetxController {
  UsersRepository usersRepository = UsersRepository();

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isLoading = false.obs;
  final Rx<ForgotPasswordStep> currentStep = ForgotPasswordStep.enterMobile.obs;
  String? userRole; // Store the determined role (agent/subagent)

  @override
  void onClose() {
    mobileController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  bool _validateMobile() {
    String mobile = mobileController.text.trim();
    if (mobile.isEmpty || mobile.length != 10) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Validation Error',
        message: 'Mobile number must be 10 digits.',
      );
      return false;
    }
    return true;
  }

  bool _validateOtp() {
    String otp = otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Validation Error',
        message: 'OTP must be 6 digits.',
      );
      return false;
    }
    return true;
  }

  bool _validatePasswords() {
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Validation Error',
        message: 'New password cannot be empty.',
      );
      return false;
    }

    if (newPassword.length < 6) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Validation Error',
        message: 'Password must be at least 6 characters long.',
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Validation Error',
        message: 'Passwords do not match.',
      );
      return false;
    }

    return true;
  }

  Future<void> sendOtp() async {
    if (!_validateMobile()) return;

    isLoading.value = true;
    String mobile = mobileController.text.trim();

    try {
      // First try with 'agent' role
      try {
        final response = await usersRepository.forgotPassword(
          mobile: mobile,
          role: 'agent',
        );

        if (response.statusCode == 200) {
          userRole = 'agent';
          currentStep.value = ForgotPasswordStep.enterOtp;
          SnackbarUtil.showSuccessSnackbar(
            title: 'Success',
            message: 'OTP sent to your mobile number.',
          );
          return;
        }
      } on DioException catch (e) {
        // If 404, continue to try subagent
        if (e.response?.statusCode != 404) {
          rethrow; // Re-throw if it's not a 404 error
        }
      }

      // If agent failed with 404, try with 'subagent' role
      try {
        final response = await usersRepository.forgotPassword(
          mobile: mobile,
          role: 'subagent',
        );

        if (response.statusCode == 200) {
          userRole = 'subagent';
          currentStep.value = ForgotPasswordStep.enterOtp;
          SnackbarUtil.showSuccessSnackbar(
            title: 'Success',
            message: 'OTP sent to your mobile number.',
          );
          return;
        }
      } on DioException catch (e) {
        // If both failed with 404, show user not found
        if (e.response?.statusCode == 404) {
          SnackbarUtil.showErrorSnackbar(
            title: 'Error',
            message: 'No agent or subagent found with this mobile number.',
          );
          return;
        }
        rethrow; // Re-throw if it's not a 404 error
      }
    } on DioException catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message: e.message ?? 'Something went wrong. Please try again.',
      );
    } catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message: 'An unexpected error occurred. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (!_validateOtp()) return;

    // Just move to next step for password entry without API call
    currentStep.value = ForgotPasswordStep.enterNewPassword;
    SnackbarUtil.showSuccessSnackbar(
      title: 'Success',
      message: 'Enter your new password.',
    );
  }

  Future<void> resetPassword() async {
    if (!_validatePasswords()) return;

    isLoading.value = true;

    try {
      // Hit the reset-password API with all required data
      final response = await usersRepository.resetPassword(
        mobile: mobileController.text.trim(),
        otp: otpController.text.trim(),
        role: userRole!,
        newPassword: newPasswordController.text,
      );

      if (response.statusCode == 200) {
        // Reset form and close modal first
        resetForm();
        Get.back(); // Close the modal

        // Show success message after modal is closed
        SnackbarUtil.showSuccessSnackbar(
          title: 'Password Updated',
          message:
              'Password reset successfully. You can now login with your new password.',
        );
      } else {
        SnackbarUtil.showErrorSnackbar(
          title: 'Error',
          message: 'Failed to reset password. Please try again.',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        SnackbarUtil.showErrorSnackbar(
          title: 'Invalid OTP',
          message:
              'The OTP you entered is invalid. Please check and try again.',
        );
      } else if (e.response?.statusCode == 404) {
        SnackbarUtil.showErrorSnackbar(
          title: 'User Not Found',
          message: 'No user found with this mobile number.',
        );
      } else {
        SnackbarUtil.showErrorSnackbar(
          title: 'Error',
          message: e.message ?? 'Something went wrong. Please try again.',
        );
      }
    } catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message: 'An unexpected error occurred. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    mobileController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    currentStep.value = ForgotPasswordStep.enterMobile;
    userRole = null;
    isLoading.value = false;
  }
}
