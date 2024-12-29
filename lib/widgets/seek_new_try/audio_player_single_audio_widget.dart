import 'package:flutter/material.dart';
import 'package:self_code/widgets/seek_new_try/seamless_audio_player_single_audio.dart';
import '../../models/audio.dart';

class AudioPlayerSingleAudioWidget extends StatefulWidget {
  final Audio audioFile;
  final bool autoplayEnabled;

  AudioPlayerSingleAudioWidget({Key? key, required this.audioFile, this.autoplayEnabled = false}) : super(key: key);

  @override
  _AudioPlayerSingleAudioWidgetState createState() => _AudioPlayerSingleAudioWidgetState();
}

class _AudioPlayerSingleAudioWidgetState extends State<AudioPlayerSingleAudioWidget> {
  late SeamlessAudioPlayerSingleAudio _audioPlayer;
  late Stream<Duration> _positionStream = Stream<Duration>.empty();
  bool _isPlaying = false; // State to track play/pause status

  @override
  void initState() {
    super.initState();
    _audioPlayer = SeamlessAudioPlayerSingleAudio(widget.audioFile, autoplayEnabled: widget.autoplayEnabled);

    _audioPlayer.initialize().then((_) {
      if (mounted && widget.autoplayEnabled) {
        _audioPlayer.play();
      }
      setState(() {
        _positionStream = _audioPlayer.currentPositionStream;
        _isPlaying = widget.autoplayEnabled;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _audioPlayer.play();
    } else {
      _audioPlayer.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: _togglePlayPause,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 200),
        if (_audioPlayer.isDurationAvailable)
          StreamBuilder<Duration>(
            stream: _positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final totalDuration = _audioPlayer.totalDuration;
              return Slider(
                activeColor: Colors.deepPurple,
                inactiveColor: Colors.grey,
                value: position.inMilliseconds.toDouble().clamp(0.0, totalDuration.inMilliseconds.toDouble()),
                min: 0,
                max: totalDuration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  final newPosition = Duration(milliseconds: value.round());
                  _audioPlayer.seek(newPosition);
                },
              );
            },
          ),
        if (!_audioPlayer.isDurationAvailable)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("Playing without a seek bar"),
          ),
      ],
    );
  }
}
