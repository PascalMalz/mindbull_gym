import 'package:just_audio/just_audio.dart';

class AudioPlaybackManager {
  final player = AudioPlayer();

  // Play a specific audio file from its path.
  Future<void> playAudio(String path) async {
    await player.setAsset(path);
    await player.play();
  }

  // Pause the currently playing audio.
  void pauseAudio() {
    player.pause();
  }

  // Check if the audio is currently playing.
  bool get isPlaying => player.playing;

  // Dispose of the player to free up resources.
  void dispose() {
    player.dispose();
  }
}
