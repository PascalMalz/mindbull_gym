// Filename: media_editor_page.dart

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../provider/audio_list_provider.dart';
import '../widgets/combined_seek_bar.dart';

class AfterJoin_save extends StatefulWidget {
  @override
  _AfterJoinState createState() => _AfterJoinState();
}

class _AfterJoinState extends State<AfterJoin_save> {
  late AudioPlayer _player;
  double position = 0.0; // Current position of the song being played, used for the slider



  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initializePlayer();
    final audioProvider = Provider.of<AudioListProvider>(context, listen: false);
    final audioFiles = audioProvider.compositionAudios;
    final audioSources = audioFiles.map((file) => AudioSource.uri(Uri.parse(file.content.clientAppAudioFilePath))).toList();
    final concatenatedAudioSource = ConcatenatingAudioSource(children: audioSources);

  }

  _initializePlayer() async {
    // Let's say you have a list of audio files as URIs
    // ConcatenatingAudioSource can play them as if they were one track
    var songs = ConcatenatingAudioSource(
      children: [
        // Example audio sources, replace with your actual audio sources
        AudioSource.uri(Uri.parse("audio1.mp3")),
        AudioSource.uri(Uri.parse("audio2.mp3")),
        // Add more songs
      ],
    );

    _player.setAudioSource(songs);
    _player.positionStream.listen((p) {
      setState(() {
        position = p.inMilliseconds.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media Editor')),
      body: Column(
        children: [
          // 1. Media player on top for preview
          Container(
            height: 200, // fixed height for demo purposes
            color: Colors.black,
            child: Center(
              child: IconButton(
                icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                onPressed: () {
                  if (_player.playing) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                },
              ),
            ),
          ),

          // 2. Main track for songs (display only)
          Container(
            height: 100, // fixed height for demo purposes
            color: Colors.blue[50],
            child: Slider(
              value: position,
              onChanged: (newPosition) {
                _player.seek(Duration(milliseconds: newPosition.toInt()));
              },
              max: _player.duration?.inMilliseconds.toDouble() ?? 100.0, // Assuming 100 is the max duration for demo
            ),
          ),

          // TODO: 3. Background music track
          // TODO: 4. Images track
          CombinedSeekBar(),
          ElevatedButton(
            onPressed: () {
              // Save or proceed to the next step
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
