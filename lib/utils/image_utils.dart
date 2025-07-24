import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';

enum CropType { profile, idProof }

class ImageUtils {
  static Future<File?> cropImage({
    required File imageFile,
    CropType cropType = CropType.profile,
  }) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(
        ratioX: cropType == CropType.profile ? 2.5 : 20,
        ratioY: cropType == CropType.profile ? 3.5 : 10,
      ), // Square crop for profile
      uiSettings: [
        AndroidUiSettings(
          aspectRatioPresets: [CropAspectRatioPreset.square],
          toolbarTitle: 'Align in frame',
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
      // compress image
      final compressedImage = await FlutterImageCompress.compressWithFile(
        croppedImage.path,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      if (compressedImage != null) {
        final compressedFile = File('${croppedImage.path}_compressed.jpg');
        await compressedFile.writeAsBytes(compressedImage);
        return compressedFile;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
