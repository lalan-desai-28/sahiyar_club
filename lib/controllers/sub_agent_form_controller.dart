import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/sub_agents_list_controller.dart';
import 'package:sahiyar_club/models/user.dart';
import 'package:sahiyar_club/repositories/users_repository.dart';
import 'package:sahiyar_club/statics/app_statics.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

import '../app/routes/app_routes.dart';

class SubAgentFormController extends GetxController {
  // Handle both single User and edit arguments map
  User? updateArg;

  final UsersRepository _usersRepository = UsersRepository();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final nickNameController = TextEditingController();

  final isLoading = false.obs;
  final isActive = true.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    populateFields();
  }

  void _parseArguments() {
    final arguments = Get.arguments;

    if (arguments is User) {
      // Direct User object (backward compatibility)
      updateArg = arguments;
    } else if (arguments is Map) {
      // Map with edit parameters
      final bool isEdit = arguments['isEdit'] ?? false;
      if (isEdit && arguments['subAgent'] is User) {
        updateArg = arguments['subAgent'] as User;
      }
    }
  }

  void populateFields() {
    if (updateArg != null) {
      fullNameController.text = updateArg?.fullName ?? '';
      emailController.text = updateArg?.email ?? '';
      mobileController.text = updateArg?.mobile ?? '';
      nickNameController.text = updateArg?.nickName ?? '';
      isActive.value = updateArg?.isActive ?? true;
    }
  }

  bool get isEditMode => updateArg != null;

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? validateNickName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nick name is required';
    }
    if (value.trim().length < 2) {
      return 'Nick name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    if (!GetUtils.isPhoneNumber(value.trim()) || value.trim().length != 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (!isEditMode && (value == null || value.trim().isEmpty)) {
      return 'Password is required';
    }
    if (value != null && value.trim().isNotEmpty && value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> createSubAgent() async {
    if (isLoading.value) return;

    if (!formKey.currentState!.validate()) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Validation Error',
        message: 'Please fix the errors in the form',
      );
      return;
    }

    if (AppStatics.currentUser == null) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message: 'Something went wrong, Please restart the app and try again.',
      );
      return;
    }

    isLoading.value = true;

    try {
      if (isEditMode) {
        await _updateSubAgent();
      } else {
        await _createSubAgent();
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

  Future<void> _updateSubAgent() async {
    try {
      final result = await _usersRepository.updateSubAgent(
        id: updateArg!.id!,
        nickName: nickNameController.text.trim(),
        fullname: fullNameController.text.trim(),
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        password:
            passwordController.text.trim().isEmpty
                ? null
                : passwordController.text.trim(),
        isActive: isActive.value,
      );

      _handleApiResponse(
        result,
        successMessage: 'Sub Agent updated successfully',
        isUpdate: true,
      );
    } catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message:
            'Failed to update Sub Agent. Please check your connection and try again.',
      );
    }
  }

  Future<void> _createSubAgent() async {
    try {
      final result = await _usersRepository.createSubAgent(
        nickName: nickNameController.text.trim(),
        fullname: fullNameController.text.trim(),
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        password: passwordController.text.trim(),
        parentAgentId: AppStatics.currentUser?.id ?? '',
        parentAgentCode: AppStatics.currentUser?.agentCode ?? '',
      );

      _handleApiResponse(
        result,
        successMessage: 'Sub Agent created successfully',
        isUpdate: false,
      );
    } catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message:
            'Failed to create Sub Agent. Please check your connection and try again.',
      );
    }
  }

  void _handleApiResponse(
    dynamic result, {
    required String successMessage,
    required bool isUpdate,
  }) {
    final expectedSuccessCode = isUpdate ? 200 : 201;

    if (result.statusCode == expectedSuccessCode) {
      SnackbarUtil.showSuccessSnackbar(
        title: 'Success',
        message: successMessage,
      );
      _navigateToSubAgentsList();
    } else if (result.statusCode == 400) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Validation Error',
        message:
            'Input data is invalid or this mobile number/email is already in use.',
      );
    } else if (result.statusCode == 409) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Conflict',
        message: 'This mobile number or email is already registered.',
      );
    } else {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message:
            isUpdate
                ? 'Failed to update Sub Agent! Please try again later.'
                : 'Failed to create Sub Agent! Please try again later.',
      );
    }
  }

  void _navigateToSubAgentsList() {
    resetForm();
    // Navigate back to sub agents list instead of home
    Get.offNamedUntil(AppRoutes.SUB_AGENTS_LIST, (route) => route.isFirst);

    // Refresh the list
    try {
      Get.find<SubAgentsListController>().fetchSubAgents();
    } catch (e) {
      // Controller might not be initialized, that's okay
      debugPrint('SubAgentsListController not found: $e');
    }
  }

  void resetForm() {
    fullNameController.clear();
    emailController.clear();
    mobileController.clear();
    nickNameController.clear();
    passwordController.clear();
    isActive.value = true;
    formKey.currentState?.reset();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    nickNameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
