import 'package:flutter/cupertino.dart';
import 'dart:io';

class SingleImageProvider extends ChangeNotifier {
  String? imagePath;  // Path of the selected image

  void setImagePath(String path) {
    imagePath = path;
    notifyListeners();
  }

  void clearImage() {
    imagePath = null;
    notifyListeners();
  }

  // Method to get an ImageProvider from the imagePath
  ImageProvider<Object>? getImage() {
    if (imagePath != null) {
      return FileImage(File(imagePath!));
    }
    return null;
  }

}
