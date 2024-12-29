import 'package:flutter/foundation.dart';

enum MediaType { video, audio, image, unknown }

class MediaItem {
  final String path;
  final MediaType type;
  Uint8List? thumbnail; // This is the added line to store the selected thumbnail
  MediaItem({required this.path, required this.type, this.thumbnail});
}

class MediaListProvider with ChangeNotifier {
  List<MediaItem> _mediaItems = [];

  List<MediaItem> get mediaItems => _mediaItems;

  void addMediaItem(MediaItem mediaItem) {
    _mediaItems.add(mediaItem);
    notifyListeners();
  }

  void removeMediaItem(int index) {
    _mediaItems.removeAt(index);
    notifyListeners();
  }

  void updateMediaItemThumbnail(int index, Uint8List thumbnail) {
    mediaItems[index].thumbnail = thumbnail;
    notifyListeners();
  }

}
