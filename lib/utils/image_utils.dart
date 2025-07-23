import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageUtils {
  static Future<File?> cropImage(File imageFile) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(
        ratioX: 2.5,
        ratioY: 3.5,
      ), // Square crop for profile
      uiSettings: [
        AndroidUiSettings(
          aspectRatioPresets: [CropAspectRatioPreset.square],
          toolbarTitle: 'Crop Profile Photo',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true, // Lock to square aspect ratio

          showCropGrid: true,
          hideBottomControls: false,
          cropGridRowCount: 3,
          cropGridColumnCount: 3,
        ),
        IOSUiSettings(
          title: 'Crop Profile Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
      ],
    );

    if (croppedImage != null) {
      return File(croppedImage.path);
    } else {
      return null;
    }
  }
}
