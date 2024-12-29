import 'dart:async';

import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:self_code/models/composition_audio.dart';

import '../../models/audio.dart';
import '../../models/composition.dart';
import '../../services/composition_flattener.dart';

class SeamlessAudioPlayerComposition {
  final Composition composition;
  List<CompositionAudio> compositionAudios;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentFileIndex = 0;
  int _currentRepetition = 0;
  Duration _totalDuration = Duration.zero;
  bool _isDurationAvailable = true;
  Timer? _positionUpdateTimer;
  Duration _lastUpdatedPosition = Duration.zero;
  final int _updateFrequencyMillis = 1000;  // Update frequency in milliseconds
  bool autoplayEnabled;
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  Stream<Duration> get currentPositionStream => _positionController.stream;

  SeamlessAudioPlayerComposition(this.composition, {this.autoplayEnabled = false}) : compositionAudios = [];

  CompositionFlattener flattener = CompositionFlattener();



  Future<void> initialize() async {
    // Use CompositionFlattener to flatten the composition
    CompositionFlattener flattener = CompositionFlattener();
    print('call to flatten composition: ${composition.compositionAudios}');
    for (var audio in composition.compositionAudios){
      print('audio.content: ${audio.content}');
    }
    print(composition.toString());
    compositionAudios = flattener.flattenComposition(composition);
    print('compositionAudios: $compositionAudios');
    for (var compAudio in compositionAudios) {

      if (compAudio.content.durationInMilliseconds == 0) {
        await _audioPlayer.setUrl(compAudio.content.clientAppAudioFilePath);
        var duration = await _audioPlayer.durationFuture;
        if (duration != null) {
          compAudio.content.durationInMilliseconds = duration.inMilliseconds;
          _totalDuration += duration * compAudio.audioRepetition;
        } else {
          _isDurationAvailable = false; // Duration not available
        }
      } else {
        _totalDuration += Duration(milliseconds: compAudio.content.durationInMilliseconds) * compAudio.audioRepetition;
      }
    }
    _audioPlayer.positionStream.listen((position) {
      _updateCurrentPosition();
    });
    if (_isDurationAvailable && autoplayEnabled) {
      await _playFileAtIndex(0);
    } else {
      // Play without seek bar if duration is not available
      await _audioPlayer.setUrl(compositionAudios.first.content.clientAppAudioFilePath
      );
    }
    // Set up a timer to periodically update the position stream
    _positionUpdateTimer = Timer.periodic(Duration(milliseconds: _updateFrequencyMillis), (timer) {
      var currentPosition = _calculateCurrentPosition();
      _positionController.add(currentPosition);
    });

    // Listen for the end of playback
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // If this is the last repetition of the last file
        if (_currentFileIndex == compositionAudios.length - 1 && _currentRepetition == compositionAudios[_currentFileIndex].audioRepetition - 1) {
          _positionController.add(_totalDuration); // Signal the end of the total playback
        } else {
          _playNextFile(); // Or continue to the next file/repetition
        }
      }
    });


  }


  // Calculate the current position, including repetitions
  Duration _calculateCurrentPosition() {
    var cumulative = Duration.zero;
    for (int i = 0; i < _currentFileIndex; i++) {
      cumulative += Duration(milliseconds: compositionAudios[i].content.durationInMilliseconds) * compositionAudios[i].audioRepetition;
    }
    cumulative += Duration(milliseconds: _currentRepetition * compositionAudios[_currentFileIndex].content.durationInMilliseconds as int);
    cumulative += _audioPlayer.position;
    //print("Calculated Current Position: ${cumulative.inMilliseconds} milliseconds");
    return cumulative;

  }


  Future<void> _playFileAtIndex(int index) async {
    _currentFileIndex = index; // Ensure this is the intended functionality
    await _audioPlayer.setUrl(compositionAudios[index].content.clientAppAudioFilePath);
    // Remove or comment out the _audioPlayer.play(); line to prevent automatic playing
    if (autoplayEnabled) {
      _audioPlayer.play();
    }
  }



  void _updateCurrentPosition() {
    var cumulative = Duration.zero;
    for (int i = 0; i < _currentFileIndex; i++) {
      cumulative += Duration(milliseconds: compositionAudios[i].content.durationInMilliseconds) * compositionAudios[i].audioRepetition;
    }
    cumulative += _audioPlayer.position;

    // Ensure we're emitting the correct position considering the repetitions of the current file
    cumulative += Duration(milliseconds: _currentRepetition * compositionAudios[_currentFileIndex].content.durationInMilliseconds as int);

    _positionController.add(cumulative);
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
    Duration cumulative = Duration.zero;

    for (var i = 0; i < compositionAudios.length; i++) {
      var fileDuration = Duration(milliseconds: compositionAudios[i].content.durationInMilliseconds);
      var fileTotalDuration = fileDuration * compositionAudios[i].audioRepetition;

      // Check if the seek position is within the total duration range of the current audio file, considering repetitions
      if (position < cumulative + fileTotalDuration) {
        var positionInCurrentFile = position - cumulative;
        var repetitionIndex = positionInCurrentFile.inMilliseconds ~/ fileDuration.inMilliseconds;
        repetitionIndex = min(repetitionIndex, compositionAudios[i].audioRepetition - 1);
        var positionInRepetition = positionInCurrentFile.inMilliseconds % fileDuration.inMilliseconds;

        // Seek to the exact position within the current repetition
        if (i != _currentFileIndex) {
          // If seeking to a different file, set the URL for the new file
          await _audioPlayer.setUrl(compositionAudios[i].content.clientAppAudioFilePath);
        }
        await _audioPlayer.seek(Duration(milliseconds: positionInRepetition));

        // Update the current file index and repetition index
        _currentFileIndex = i;
        _currentRepetition = repetitionIndex;
        print('repetitionIndex: $repetitionIndex');
        // Emit the correct cumulative position including the repetitions
        var correctPosition = cumulative + Duration(milliseconds: positionInRepetition);
        correctPosition += Duration(milliseconds: repetitionIndex * fileDuration.inMilliseconds);

        print('correctPosition: $correctPosition');

        _positionController.add(correctPosition);
        break;
      }

      cumulative += fileTotalDuration;
    }
  }


  Future<void> _playNextFile() async {
    print("Current File Index: $_currentFileIndex, Current Repetition: $_currentRepetition");

    // Increment repetition or move to the next file as needed
    if (_currentRepetition < compositionAudios[_currentFileIndex].audioRepetition - 1) {
      // Increment repetition for the current file
      _currentRepetition++;
    } else {
      // Move to the next file
      _currentFileIndex++;
      _currentRepetition = 0; // Reset repetition for the new file

      if (_currentFileIndex >= compositionAudios.length) {
        // Reached the end of the playlist
        _currentFileIndex = 0; // Consider what behavior you want at the end of the playlist
        // Stop or loop the playlist
        return;
      }
    }

    // Play the file at the new index or repeat the current one
    await _playFileAtIndex(_currentFileIndex);
  }








  Duration get totalDuration => _totalDuration;

  bool get isDurationAvailable => _isDurationAvailable;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionUpdateTimer?.cancel();
    _positionController.close();
  }
}

