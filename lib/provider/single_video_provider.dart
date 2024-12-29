import 'dart:io';
import 'package:flutter/material.dart';

class SingleVideoProvider with ChangeNotifier {
  File? _videoFile;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  SingleVideoProvider() {
    // Set up listeners for the text controllers
    descriptionController.addListener(_updateDescription);
    tagsController.addListener(_updateTags);
  }

  File? get videoFile => _videoFile;

  set videoFile(File? file) {
    _videoFile = file;
    notifyListeners();
  }

  void _updateDescription() {
    // Call notifyListeners if you need to update the UI
    notifyListeners();
  }

  void _updateTags() {
    // Call notifyListeners if you need to update the UI
    notifyListeners();
  }

  void clear() {
    _videoFile = null;
    descriptionController.clear();
    tagsController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // Always dispose controllers when the provider is disposed
    descriptionController.removeListener(_updateDescription);
    descriptionController.dispose();
    tagsController.removeListener(_updateTags);
    tagsController.dispose();
    super.dispose();
  }
}

