//todo chack when it is needed e.g. in local file page I dont use i, but in record page ... Why?

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../models/audio.dart';

class SingleAudioProvider extends ChangeNotifier {
  Audio? audioFile;
  String? _audioFilePath;
  int _audioDurationInMilliseconds = 0;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController audioTagController = TextEditingController();
  final TextEditingController audioTitleController = TextEditingController();

  SingleAudioProvider()
      : audioFile = Audio(
          clientAppAudioFilePath: '',
          id: '',
          title: '',
        ) {
    // Initialize audioFile within the initializer list
  }
  @override
  void dispose() {
    descriptionController.dispose();
    audioTagController.dispose();
    super.dispose();
  }

  void setAudioFile(Audio file) {
    audioFile = file;
  }

  // Getter for audioFilePath
  int get audioDurationInMilliseconds => _audioDurationInMilliseconds;

  // Setter for audioFilePath
  void setAudioDurationInMilliseconds(int duration) {
    _audioDurationInMilliseconds = duration;
    notifyListeners();
  }

  // Getter for audioFilePath
  String? get audioFilePath => _audioFilePath;

  // Setter for audioFilePath
  void setAudioFilePath(String path) {
    _audioFilePath = path;
    notifyListeners();
  }

  void updateAudioDescription(String description) {
    audioFile?.description = description;
    notifyListeners();
  }

  void clearAudio() {
    audioFile = null; // Clearing the audioFile
    notifyListeners();
  }

  void addTagToAudioById(String tag) {
    audioFile?.tags.add(tag);
    notifyListeners();
  }

  void removeTagFromAudioById(String tag) {
    audioFile?.tags.remove(tag);
    notifyListeners();
  }
}
