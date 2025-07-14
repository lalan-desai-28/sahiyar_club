// Optimized OTP Controller
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/repositories/users_repository.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/utils/hive_database.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class OtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final RxBool isLoading = false.obs;
  final UsersRepository _usersRepository = UsersRepository();

  String get mobile => Get.arguments['mobile'] as String;

  void validateOtp(String otp) async {
    if (!_isValidOtp(otp)) return;

    isLoading.value = true;
    try {
      final response = await _usersRepository.validateOtp(
        mobile: mobile,
        otp: otp,
      );
      _handleResponse(response);
    } on DioException catch (e) {
      _showError(e.message.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidOtp(String otp) {
    if (otp.length != 6) {
      _showError('OTP must be 6 digits long');
      return false;
    }
    return true;
  }

  void _handleResponse(dynamic response) {
    if (response.statusCode == 200) {
      _saveUserAndNavigate(response.data);
    } else {
      _showError('Invalid OTP');
    }
  }

  void _saveUserAndNavigate(dynamic userData) {
    Get.find<HiveDatabase>().saveToken(userData?.token ?? '');
    AppStatics.currentUser = userData;
    Get.offAllNamed('/home');
  }

  void _showError(String message) {
    SnackbarUtil.showErrorSnackbar(title: 'Error', message: message);
  }
}
