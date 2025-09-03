import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sahiyar_club/repositories/pass_repository.dart';
import 'package:sahiyar_club/utils/image_utils.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

class CreatePassController extends GetxController {
  // Dependencies
  final PassRepository _passRepository = PassRepository();
  static final ImagePicker _imagePicker = ImagePicker();
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  // Form Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  // Reactive Variables
  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<File?> idProofImage = Rx<File?>(null);
  final Rx<DateTime> selectedDate =
      DateTime.now().subtract(const Duration(days: 365 * 13)).obs;
  final RxString gender = 'Male'.obs;
  final RxBool isPaymentDone = true.obs;
  final RxBool isLoading = false.obs;
  final RxInt uploadProgress = 0.obs;

  // Constants for validation
  static const int _minNameLength = 3;
  static const int _mobileLength = 10;

  // Precompiled regex patterns for better performance
  static final RegExp _mobileFormatRegex = RegExp(r'^\d{10}$');
  static final RegExp _mobileStartRegex = RegExp(r'^[9876]');
  static final List<RegExp> _repeatingDigitRegexes = List.generate(
    10,
    (i) => RegExp('$i{7,}'),
  );

  @override
  void onClose() {
    fullNameController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  // Optimized mobile number validation
  bool _validateMobileNumber(String number) {
    // Basic format check
    if (!_mobileFormatRegex.hasMatch(number)) return false;
    if (!_mobileStartRegex.hasMatch(number)) return false;

    // Check for excessive digit repetition
    for (final regex in _repeatingDigitRegexes) {
      if (regex.hasMatch(number)) return false;
    }

    // Check for repeated patterns
    return !_hasExcessivePatternRepetition(number);
  }

  bool _hasExcessivePatternRepetition(String number) {
    for (int patternSize = 2; patternSize <= 4; patternSize++) {
      for (int i = 0; i <= number.length - patternSize * 4; i++) {
        final pattern = number.substring(i, i + patternSize);
        final repeatedPattern = pattern * 4;
        if (number.contains(repeatedPattern)) return true;
      }
    }
    return false;
  }

  // Optimized form validation
  bool isFormValid() {
    final validations = [
      _validateFullName,
      _validateMobile,
      _validateProfileImage,
      _validateIdProofImage,
    ];

    for (final validation in validations) {
      if (!validation()) return false;
    }

    return true;
  }

  bool _validateFullName() {
    final name = fullNameController.text.trim();

    if (name.isEmpty) {
      _showValidationError('Invalid Name', 'Full name cannot be empty!');
      return false;
    }

    if (name.length < _minNameLength) {
      _showValidationError(
        'Invalid Name',
        'Full name must be at least $_minNameLength characters long!',
      );
      return false;
    }

    final names = name.split(' ');
    if (names.length < 2 || names[0].toLowerCase() == names[1].toLowerCase()) {
      _showValidationError(
        'Invalid Name',
        'Please enter a valid full name! It should contain both first and last names.',
      );
      return false;
    }

    return true;
  }

  bool _validateMobile() {
    final mobile = mobileController.text;

    if (mobile.isEmpty || mobile.length != _mobileLength) {
      _showValidationError(
        'Invalid Mobile Number',
        'Please enter a valid mobile number!',
      );
      return false;
    }

    if (!_validateMobileNumber(mobile)) {
      _showValidationError(
        'Invalid Mobile Number',
        'Please enter a valid mobile number!',
      );
      return false;
    }

    return true;
  }

  bool _validateProfileImage() {
    if (profileImage.value == null) {
      _showValidationError(
        'Profile Image Required',
        'Please upload a profile image!',
      );
      return false;
    }
    return true;
  }

  bool _validateIdProofImage() {
    if (idProofImage.value == null) {
      _showValidationError(
        'ID Proof Required',
        'Please upload an ID proof image!',
      );
      return false;
    }
    return true;
  }

  void _showValidationError(String title, String message) {
    SnackbarUtil.showErrorSnackbar(title: title, message: message);
  }

  // Optimized image picker with caching
  Future<String?> _showImagePickerOptions(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ImagePickerBottomSheet(),
    );
  }

  Future<void> selectIdProofImage() async {
    final source = await _showImagePickerOptions(Get.context!);
    if (source == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedFile == null) {
        _showImageSelectionError();
        return;
      }

      final croppedFile = await ImageUtils.cropImage(
        imageFile: File(pickedFile.path),
        cropType: CropType.idProof,
      );

      if (croppedFile != null) {
        idProofImage.value = File(croppedFile.path);
      } else {
        _showImageSelectionError();
      }
    } catch (e) {
      _showValidationError('Error', 'Failed to select image: $e');
    }
  }

  void _showImageSelectionError() {
    _showValidationError('Image Selection Cancelled', 'No image was selected.');
  }

  void resetForm() {
    fullNameController.clear();
    mobileController.clear();
    selectedDate.value = DateTime.now().subtract(
      const Duration(days: 365 * 13),
    );
    profileImage.value = null;
    idProofImage.value = null;

    // Hide keyboard efficiently
    final context = Get.context;
    if (context != null) {
      FocusScope.of(context).unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  Future<void> submitForm() async {
    if (isLoading.value || !isFormValid()) return;

    isLoading.value = true;

    try {
      final response = await _passRepository.createPass(
        fullname: fullNameController.text.trim(),
        dob: _dateFormatter.format(selectedDate.value),
        mobile: mobileController.text.trim(),
        gender: gender.value.toLowerCase(),
        isAmountPaid: isPaymentDone.value,
        profilePhoto: File(profileImage.value!.path),
        idProof: File(idProofImage.value!.path),
      );

      if (response.statusCode == 201) {
        final newPassCode = response.data?.passCode ?? 'Pass';
        resetForm();
        SnackbarUtil.showSuccessSnackbar(
          title: '$newPassCode created!',
          message: 'Pass created successfully!',
        );
      } else {
        _showValidationError(
          'Creation Failed',
          'Failed to create pass: ${response.statusMessage}',
        );
      }
    } catch (e) {
      _showValidationError(
        'Error',
        'An error occurred while creating the pass: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class _ImagePickerBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              _ImageSourceOption(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              _ImageSourceOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}
