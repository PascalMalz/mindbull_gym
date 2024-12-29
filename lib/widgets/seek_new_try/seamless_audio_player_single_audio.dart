import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../../models/audio.dart';

class SeamlessAudioPlayerSingleAudio {
  final Audio audioFile;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _totalDuration = Duration.zero;
  bool _isDurationAvailable = true;
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  Stream<Duration> get currentPositionStream => _positionController.stream;
  bool autoplayEnabled;

  SeamlessAudioPlayerSingleAudio(this.audioFile, {this.autoplayEnabled = false});

  Future<void> initialize() async {
    try {
      var duration = await _audioPlayer.setUrl(audioFile.clientAppAudioFilePath);
      _totalDuration = duration ?? Duration.zero;
      _isDurationAvailable = duration != null;

      if (_isDurationAvailable && autoplayEnabled) {
        _audioPlayer.play();
      }

      // Set up a listener for the current position of the audio player.
      _audioPlayer.positionStream.listen((position) {
        _positionController.add(position);
      });

      // Listen for the end of playback to handle looping or cleanup.
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          // Handle completion (e.g., repeat, stop, notify, etc.)
          _positionController.add(_totalDuration);
        }
      });
    } catch (e) {
      // Handle errors in loading or playing audio.
      print("Error initializing audio player: $e");
    }
  }

  void play() {
    if (!_audioPlayer.playing) {
      _audioPlayer.play();
    }
  }

  void pause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    }
  }

  Future<void> seek(Duration position) async {
    if (position >= Duration.zero && position <= _totalDuration) {
      await _audioPlayer.seek(position);
      _positionController.add(position);
    }
  }

  Duration get totalDuration => _totalDuration;

  bool get isDurationAvailable => _isDurationAvailable;

  void dispose() {
    _audioPlayer.dispose();
    _positionController.close();
  }
}
