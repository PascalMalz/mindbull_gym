import 'package:flutter/material.dart';
import '../../models/audio.dart';
import '../../models/composition.dart';
import 'seamless_audio_player_composition.dart';

class AudioPlayerCompositionWidget extends StatefulWidget {
  final Composition composition;
  final bool autoplayEnabled;
  AudioPlayerCompositionWidget({Key? key, required this.composition, this.autoplayEnabled = false}) : super(key: key);

  @override
  _AudioPlayerCompositionWidgetState createState() => _AudioPlayerCompositionWidgetState();
}

class _AudioPlayerCompositionWidgetState extends State<AudioPlayerCompositionWidget> {
  late SeamlessAudioPlayerComposition _audioPlayer;
  late Stream<Duration> _positionStream = Stream<Duration>.empty(); // Initialize with an empty stream




  @override
  void initState() {
    super.initState();
    _audioPlayer = SeamlessAudioPlayerComposition(widget.composition, autoplayEnabled: widget.autoplayEnabled);

    _audioPlayer.initialize().then((_) {
      if (mounted && widget.autoplayEnabled) { // Check if the widget is still in the tree and autoplay is enabled
        _audioPlayer.play();
      }
      setState(() {
        _positionStream = _audioPlayer.currentPositionStream;
      });
    });
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            InkWell(
              onTap: () {
                _audioPlayer.play();
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(50),
                ),
                child:
                    Icon(Icons.play_arrow,size: 60,color: Colors.white,),
              ),
            ),
            SizedBox(width: 30,),
            InkWell(
              onTap: () {
                _audioPlayer.pause();
              },
              child: Container(
                width: 70,
                height: 70, // Adjust padding as needed
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(50),
                ),
                child:
                Icon(Icons.pause, size: 60,color: Colors.white,),
              ),
            ),
            // Add more controls as needed
          ],
        ),
        SizedBox(height: 280,),
        if (_audioPlayer.isDurationAvailable)
          StreamBuilder<Duration>(
            stream: _audioPlayer.currentPositionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final totalDuration = _audioPlayer.totalDuration;
              double sliderValue = position.inMilliseconds.toDouble();
              sliderValue = sliderValue.clamp(0.0, totalDuration.inMilliseconds.toDouble());
              return Slider(
                activeColor: Colors.white,
                inactiveColor: Colors.white,
                value: sliderValue,
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
