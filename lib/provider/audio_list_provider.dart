import 'package:flutter/foundation.dart';
import '../models/audio.dart';
import '../models/composition.dart';
import '../models/composition_audio.dart';
import '../models/composition_tag.dart';
import 'package:uuid/uuid.dart';

class AudioListProvider extends ChangeNotifier {
  List<CompositionAudio> compositionAudios = [];
  String listDescription = "";
  String listTitle = "";
  List<String> listTags = [];

  void addCompositionAudio(dynamic content, int audioPosition, int audioRepetition) {
    compositionAudios.add(CompositionAudio(
      content: content,
      audioPosition: audioPosition,
      audioRepetition: audioRepetition,
    ));
    notifyListeners();
  }

  void updateCompositionAudio(String id, int newAudioPosition, int newAudioRepetition) {
    for (var compAudio in compositionAudios) {
      if (compAudio.compositionAudioId == id) {
        compAudio.audioPosition = newAudioPosition;
        compAudio.audioRepetition = newAudioRepetition;
        break;
      }
    }
    notifyListeners();
  }

  void removeCompositionAudio(String id) {
    compositionAudios.removeWhere((compAudio) => compAudio.compositionAudioId == id);
    notifyListeners();
  }


  void setListTitle(String title) {
    listTitle = title;
    notifyListeners();
  }

  void setListDescription(String description) {
    listDescription = description;
    notifyListeners();
  }

  void addTagToList(String tag) {
    if (!listTags.contains(tag)) {
      listTags.add(tag);
    }
    notifyListeners();
  }

  void removeTagFromList(String tag) {
    listTags.remove(tag);
    notifyListeners();
  }


  void updateAudioFileDescription(String audioId, String newDescription) {
    for (var compAudio in compositionAudios) {
      if (compAudio.content is Audio && compAudio.content.id == audioId) {
        // Update description if it's an AudioFile
        compAudio.content.description = newDescription;
        break;
      }
    }
    notifyListeners();
  }


  void addTagToFileById(String fileId, String tag) {
    for (var compAudio in compositionAudios) {
      if (compAudio.content.id == fileId) {
        // Add tag if it's an AudioFile and tag is not already present
        if (!compAudio.content.tags.contains(tag)) {
          compAudio.content.tags.add(tag);
          break;
        }
      }
    }
    notifyListeners();
  }


  void removeTagFromFileById(String audioId, String tag) {
    for (var compAudio in compositionAudios) {
        compAudio.content.tags.remove(tag);
        break;
    }
    notifyListeners();
  }


  // Create Composition from the current list
  Composition createComposition() {
    var id = const Uuid().v4();
    List<CompositionTag> compositionTags = listTags.map((tag) => CompositionTag(
      tag: tag,
      createdAt: DateTime.now(),
    )).toList();

    return Composition(
      id: id,
      title: listTitle,
      description: listDescription,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      compositionAudios: List<CompositionAudio>.from(compositionAudios), //Passing copy of list not dá reference(Dart default)!
      compositionTags: compositionTags,
    );
  }

  // Clear the list
  void clearList() {
    compositionAudios.clear();
    listDescription = "";
    listTitle = "";
    listTags.clear();
    notifyListeners();
  }
// Clear all data in the provider
  void clearAll() {
    // Clearing all compositions
    compositionAudios.clear();

    // Resetting all strings to their initial state
    listDescription = "";
    listTitle = "";

    // Clearing the tags list
    listTags.clear();

    // Notify any listeners that the provider has been updated
    notifyListeners();
  }

  // Getters
  List<CompositionAudio> get getCompositionAudios => compositionAudios;
  String get getListTitle => listTitle;
  String get getListDescription => listDescription;
  List<String> get getListTags => listTags;
}
