// media_track_provider.dart

import 'package:flutter/material.dart';

class MediaTrack {
  String id;
  String title;
  String thumbnailUrl;

  MediaTrack({required this.id, required this.title, required this.thumbnailUrl});
}

class MediaTrackProvider with ChangeNotifier {
  List<MediaTrack?> _tracks = [];

  String _currentThumbnailUrl = '';

  List<MediaTrack?> get tracks => _tracks;

  String get currentThumbnailUrl => _currentThumbnailUrl;

  void addTrack(MediaTrack track) {
    _tracks.add(track);
    notifyListeners();
  }

  void updateCurrentThumbnail(String newThumbnailUrl) {
    _currentThumbnailUrl = newThumbnailUrl;
    notifyListeners();
  }

  MediaTrack? getTrackById(String id) {
    return _tracks.firstWhere((track) => track?.id == id, orElse: null);
  }



  void updateTrackThumbnail(String trackId) {
    var track = getTrackById(trackId);
    if (track != null) {
      track.thumbnailUrl = _currentThumbnailUrl;
      notifyListeners();
    }
  }
}
