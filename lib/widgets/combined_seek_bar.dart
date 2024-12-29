import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio.dart';
import '../models/composition_audio.dart';
import '../provider/audio_list_provider.dart';
import '../services/audio_playback_manager.dart';
import 'package:just_audio/just_audio.dart';

class CombinedSeekBar extends StatefulWidget {
  @override
  _CombinedSeekBarState createState() => _CombinedSeekBarState();
}

class _CombinedSeekBarState extends State<CombinedSeekBar> {
  late AudioPlaybackManager _audioPlaybackManager;
  double _currentPosition = 0.0;
  late double _totalDuration;

  @override
  void initState() {
    super.initState();
    _audioPlaybackManager = AudioPlaybackManager();
    _audioPlaybackManager.player.positionStream.listen((position) {
      setState(() {
        _currentPosition = position.inMilliseconds.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioListProvider = Provider.of<AudioListProvider>(context);

    _totalDuration = audioListProvider.compositionAudios
        .map((compAudio) {
      // Ensure that content is AudioFile and get its durationInMilliseconds
      if (compAudio.content is Audio) {
        return compAudio.content.durationInMilliseconds ?? 0;
      }
      return 0; // Return 0 if not an AudioFile or any other condition you need to handle
    })
        .fold<int>(0, (int prev, dynamic curr) {
      if (curr is int) {
        return prev + curr; // Ensure curr is int before adding
      }
      return prev; // Or handle case where curr is not an integer
    })
        .toDouble();


    return Column(
      children: [
        Slider(
          value: _currentPosition,
          onChanged: (value) {
            // Optional: Implement seeking logic if needed.
          },
          max: _totalDuration,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                _playAudio(audioListProvider.compositionAudios);
              },
            ),
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: () {
                _audioPlaybackManager.pauseAudio();
              },
            ),
          ],
        ),
      ],
    );
  }

  void _playAudio(List<CompositionAudio> compositionAudios) async {
    // Creating a list of AudioSource using the file paths.
    final audioSources = compositionAudios.map(
            (compAudio) => AudioSource.uri(Uri.parse(compAudio.content.clientAppAudioFilePath))
    ).toList();

    // Creating a ConcatenatingAudioSource with the audio sources.
    final concatenatedAudioSource = ConcatenatingAudioSource(children: audioSources);

    // Playing the concatenated audio.
    await _audioPlaybackManager.player.setAudioSource(concatenatedAudioSource);
    await _audioPlaybackManager.player.play();
  }

  @override
  void dispose() {
    _audioPlaybackManager.dispose();
    super.dispose();
  }
}
