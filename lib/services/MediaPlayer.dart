import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class MediaPlayer {
  late AudioPlayer _audioPlayer;
  VideoPlayerController? _videoPlayerController;

  MediaPlayer() {
    _audioPlayer = AudioPlayer();
  }

  // Initialize video player
  Future<void> initializeVideoPlayer(String source) async {
    // Determine if the source is a local file or a network URL
    _videoPlayerController = source.startsWith('http')
        ? VideoPlayerController.networkUrl(source as Uri)
        : VideoPlayerController.file(File(source));
    await _videoPlayerController!.initialize();
  }

  // Play audio
  Future<void> playAudio(String source) async {
    // Determine if the source is a local file or a network URL
    print('AudioPlayer try play source: $source');
    await (source.startsWith('http')
        ? _audioPlayer.setUrl(source)
        : _audioPlayer.setFilePath(source));
    _audioPlayer.play();
  }

  // Play video
  void playVideo() {
    _videoPlayerController?.play();
  }

  // Pause audio
  void pauseAudio() {
    _audioPlayer.pause();
  }

  // Pause video
  void pauseVideo() {
    _videoPlayerController?.pause();
  }

  // Seek audio
  void seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  // Seek video
  void seekVideo(Duration position) {
    _videoPlayerController?.seekTo(position);
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
    _videoPlayerController?.dispose();
  }
}
