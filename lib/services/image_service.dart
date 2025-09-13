import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Service class for handling image-related operations
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Save image to app directory
  Future<String> saveImageToAppDirectory(File imageFile, String prefix) async {
    // Get app directory
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        '$prefix-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String savedImagePath = join(appDir.path, fileName);

    // Copy image to app directory
    await imageFile.copy(savedImagePath);

    return savedImagePath;
  }

  /// Get image from path
  ImageProvider getImageFromPath(String path) {
    return FileImage(File(path));
  }

  /// Delete image
  Future<void> deleteImage(String path) async {
    final File file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
