import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/repositories/users_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class LoginController extends GetxController {
  UsersRepository usersRepository = UsersRepository();

  final TextEditingController mobileController =
      TextEditingController()..text = '';
  final TextEditingController passwordController =
      TextEditingController()..text = '';
  final RxBool isLoading = false.obs;

  bool _validate(String mobile, String password) {
    if (mobile.isEmpty || password.isEmpty || mobile.length != 10) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Validation Error',
        message: 'Mobile must be 10 digits and Password cannot be empty.',
      );
      isLoading.value = false;
      return false;
    }
    return true;
  }

  void login() async {
    String mobile = mobileController.text.trim();
    String password = passwordController.text;

    final validated = _validate(mobile, password);
    if (!validated) return;

    isLoading.value = true;

    try {
      final response = await usersRepository.login(
        mobile: mobile,
        password: password,
      );

      if (response.statusCode == 200) {
        Get.toNamed(AppRoutes.OTP, arguments: {'mobile': mobile});
      } else {
        SnackbarUtil.showErrorSnackbar(
          title: 'Login Failed',
          message: 'Invalid mobile or password.',
        );
      }
    } on DioException catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message: e.message ?? 'Something went wrong',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
