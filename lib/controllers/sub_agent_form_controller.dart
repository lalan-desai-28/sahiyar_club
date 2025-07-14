import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/repositories/users_repository.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

import '../app/routes/app_routes.dart';

class SubAgentFormController extends GetxController {
  final UsersRepository _usersRepository = UsersRepository();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  void createSubAgent() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        mobileController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    isLoading.value = true;

    try {
      final result = await _usersRepository.createSubAgent(
        fullname: fullNameController.text.trim(),
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        password: passwordController.text.trim(),
        parentAgentId: AppStatics.currentUser?.id ?? '',
      );
      if (result.statusCode == 201) {
        SnackbarUtil.showSuccessSnackbar(
          title: 'Success',
          message: 'Sub Agent created successfully',
        );
        Get.toNamed(AppRoutes.SUB_AGENTS_LIST);
      } else {
        Get.snackbar('Error', 'Failed to create Sub Agent');
      }
    } on Exception catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message: 'Failed to create Sub Agent: ${e.toString()}',
      );
    }

    isLoading.value = false;
  }
}
