import 'package:get/get.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/constants/api_config_constants.dart';
import 'package:sahiyar_club/controllers/home_controller.dart';
import 'package:sahiyar_club/models/pass_full.dart';
import 'package:sahiyar_club/repositories/pass_repository.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class UpdatePassController extends GetxController {
  final PassRepository passRepository = PassRepository();

  Rx<File?> profileImage = Rx<File?>(null);
  final Rx<File?> idProofImage = Rx<File?>(null);
  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();
  final Rx<DateTime> selectedDate =
      DateTime.now().subtract(const Duration(days: 365 * 13)).obs;
  final RxInt uploadProgress = 0.obs;

  final RxString profileNetworkImage = ''.obs;
  final RxString idProofNetworkImage = ''.obs;

  final RxString gender = 'Male'.obs;

  final RxBool isLoading = false.obs;
  final RxBool isImageUploading = false.obs;

  void loadPassData(FullPass fullPass) {
    fullNameController.text = fullPass.fullName ?? '';
    mobileController.text = fullPass.mobile ?? '';
    selectedDate.value = DateTime.parse(
      fullPass.dob ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    if (fullPass.gender != null) {
      if (fullPass.gender == "male") {
        gender.value = 'Male';
      } else if (fullPass.gender == "female") {
        gender.value = 'Female';
      } else {
        gender.value = 'Kid';
      }
    }

    // load image from network
    if (fullPass.profilePhotoUrl != null) {
      profileNetworkImage.value =
          '${ApiConstants.imageBaseUrl}${fullPass.profilePhotoUrl}';
    }
    if (fullPass.idProofUrl != null) {
      idProofNetworkImage.value =
          '${ApiConstants.imageBaseUrl}${fullPass.idProofUrl}';
    }
  }

  bool _validateMobileNumber(String number) {
    // Must be exactly 10 digits
    if (!RegExp(r'^\d{10}$').hasMatch(number)) return false;

    // Must start with 9, 8, 7, or 6
    if (!RegExp(r'^[9876]').hasMatch(number)) return false;

    // Check for any digit repeating more than 6 times (7 or more is invalid)
    for (int i = 0; i <= 9; i++) {
      if (RegExp('$i{7,}').hasMatch(number)) return false;
    }

    // Check for repeated patterns of 4 or more pairs
    // (3 pairs like "808080" is allowed, but 4 pairs like "80808080" is not)
    for (int size = 2; size <= 4; size++) {
      for (int i = 0; i <= number.length - size * 4; i++) {
        final pattern = number.substring(i, i + size);
        final repeatedPattern =
            pattern * 4; // Check if pattern repeats 4+ times
        if (number.contains(repeatedPattern)) return false;
      }
    }

    return true;
  }

  Future<String?> _showImagePickerOptions(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.of(context).pop('camera'); // <-- FIX
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.of(context).pop('gallery'); // <-- FIX
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  bool isFormValid() {
    if (fullNameController.text.isEmpty) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Invalid Name',
        message: 'Full name cannot be empty!',
      );
      return false;
    }

    if (fullNameController.text.length < 3) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Invalid Name',
        message: 'Full name must be at least 3 characters long!',
      );
      return false;
    }

    if (mobileController.text.isEmpty || mobileController.text.length != 10) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Invalid Mobile Number',
        message: 'Please enter a valid mobile number!',
      );
      return false;
    }

    if (!_validateMobileNumber(mobileController.text)) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Invalid Mobile Number',
        message: 'Please enter a valid mobile number!',
      );
      return false;
    }

    return true;
  }

  void submitForm(String passId) async {
    if (!isFormValid()) return;

    isLoading.value = true;

    try {
      // Update pass data
      final response = await passRepository.updatePass(
        passId: passId,
        fullName: fullNameController.text.trim(),
        dob: DateFormat('yyyy-MM-dd').format(selectedDate.value),
        mobile: mobileController.text.trim(),
        gender: gender.value.toLowerCase(),
      );

      if (response.statusCode == 200) {
        final updatedPassId = response.data?.sId ?? '';
        bool imageUploadSuccess = true;

        // If images exist, upload them
        if (profileImage.value != null || idProofImage.value != null) {
          isImageUploading.value = true;

          final uploadImageResponse = await passRepository
              .uploadProfileAndIdProofImage(
                passId: updatedPassId,
                profileImage:
                    profileImage.value != null
                        ? File(profileImage.value!.path)
                        : null,
                idProofImage:
                    idProofImage.value != null
                        ? File(idProofImage.value!.path)
                        : null,
                onSendProgress: (int sent, int total) {
                  uploadProgress.value = ((sent / total) * 100).toInt();
                },
              );

          if (uploadImageResponse.statusCode != 200) {
            imageUploadSuccess = false;
            SnackbarUtil.showErrorSnackbar(
              title: 'Image Upload Failed',
              message:
                  'Failed to upload images: ${uploadImageResponse.statusMessage}',
            );
          }
        }

        if (imageUploadSuccess) {
          SnackbarUtil.showSuccessSnackbar(
            title: 'Update Successful',
            message: 'Pass updated successfully!',
          );
          Get.find<HomeController>().changeTab(2); // Change page if needed
        }
      } else {
        SnackbarUtil.showErrorSnackbar(
          title: 'Update Failed',
          message: 'Failed to update pass: ${response.statusMessage}',
        );
      }
    } catch (e) {
      SnackbarUtil.showErrorSnackbar(
        title: 'Error',
        message: 'An error occurred while updating the pass: $e',
      );
    } finally {
      isLoading.value = false;
      isImageUploading.value = false;
      Get.offNamed(AppRoutes.HOME);
    }
  }

  void selectIdProofImage() async {
    final source = await _showImagePickerOptions(Get.context!);
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 16,
    );

    if (pickedFile != null) {
      idProofImage.value = File(pickedFile.path);
    } else {
      SnackbarUtil.showErrorSnackbar(
        title: 'Image Selection Cancelled',
        message: 'No image was selected.',
      );
    }
  }
}
