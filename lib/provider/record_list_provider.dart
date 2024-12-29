import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/audio.dart';

// This provider is only used for records!!! not fo general audio files.

class RecordListProvider extends ChangeNotifier {
  final Box _metadataBox;

  RecordListProvider(this._metadataBox);

  List<Audio> get audioFiles {
    // Directly cast the box as Box<AudioFile> if not done already during initialization
    var box = _metadataBox as Box<Audio>;

    // Retrieve all AudioFile objects directly
    List<Audio> files = box.values.toList();

    // Sort the list based on timestamp or any other property
    files.sort((a, b) => b.userTimeStamp.compareTo(a.userTimeStamp));

    return files;
  }


  String listDescription = "";
  String listTitle = "";
  List<String> listTags = [];

  void setListTags(List<String> tags) {
    listTags = tags;
    notifyListeners();
  }
  void addTagToList(String tag) {
    listTags.add(tag);
    print('Tags after adding: $listTags'); // Make sure this line is present
    notifyListeners();
  }


  List<String> getListTags(){
    return listTags;
  }

  void removeTagFromList(String tag) {
    listTags.remove(tag);
  }

  void setListTitle(String title) {
    listTitle = title;
    notifyListeners();
  }

  void setListDescription(String description) {
    listDescription = description;
    notifyListeners();
  }

  void addAudioFile(Audio file) {
    _metadataBox.add(file);
    notifyListeners();
  }

  void removeAudioFile(Audio file) {
    _metadataBox.delete(file.id); // Assuming 'key' is how you reference Hive entries
    notifyListeners();
  }

/*
  void updateOrder(List<AudioFile> newOrder) {
    audioFiles = newOrder;
    notifyListeners();
  }
*/

  void updateAudioDescription(String id, String description) {
    for (Audio file in audioFiles) {
      if (file.id == id) {
        file.description = description;
        break;
      }
    }
    notifyListeners();
  }

  void clearList() {
    audioFiles.clear();
    listDescription = "";
    listTitle = "";
    notifyListeners();
    listTags = [];
  }
  void addTagToAudioById(String audioId, String tag) {
    for (Audio file in audioFiles) {
      if (file.id == audioId) {
        file.tags.add(tag);
        break;
      }
    }
    notifyListeners();
  }

  void removeTagFromAudioById(String audioId, String tag) {
    for (Audio file in audioFiles) {
      if (file.id == audioId) {
        file.tags.remove(tag);
        break;
      }
    }
    notifyListeners();
  }
}
