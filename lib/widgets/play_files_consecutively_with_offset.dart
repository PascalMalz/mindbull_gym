import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class playFilesConsecutivelyWithOffset extends StatefulWidget {
  final List<Map<String, dynamic>> audioFiles;
  final Duration duration;
  final int offset;
  final Function(bool isPlaying) onAudioFilePlayingStateChanged; // New callback function

  playFilesConsecutivelyWithOffset({
    required this.audioFiles,
    required this.duration,
    required this.offset,
    required this.onAudioFilePlayingStateChanged, // Pass the callback function as a parameter
  });

  @override
  _playFilesConsecutivelyWithOffsetState createState() =>
      _playFilesConsecutivelyWithOffsetState();
}

class _playFilesConsecutivelyWithOffsetState extends State<playFilesConsecutivelyWithOffset> {
  int currentIndex = 0;
  bool isPlaying = false; // Track the state of the audioFiles playing

  @override
  void initState() {
    super.initState();
    playAudioFiles();
    print('playFilesConsecutivelyWithOffset initialized');
  }

  void playAudioFiles() async {
    print('Offset: ${widget.offset} seconds');
    for (var i = 0; i < widget.audioFiles.length; i++) {
      final audioFile = widget.audioFiles[i];
      setState(() {
        currentIndex = i; // Update the currentIndex
        isPlaying = true; // Set isPlaying to true when audioFiles start playing
      });
      print('Now playing: $audioFile');
      print('Duration: ${audioFile['duration']} seconds');
      print('Duration: ${audioFile['repetition']} seconds');
      print('Playing...');
      // Your code to play the audioFile here

      await Future.delayed(Duration(milliseconds: widget.audioFiles[i]['durationMilliseconds'] * widget.audioFiles[i]['repetition']));
      print('AudioFile finished playing.');

      if (i < widget.audioFiles.length - 1) {
        await Future.delayed(Duration(seconds: widget.offset));
      }
    }

    setState(() {
      isPlaying = false; // Set isPlaying to false when audioFiles finish playing
    });
    widget.onAudioFilePlayingStateChanged(isPlaying); // Notify the callback function
  }

  @override
  Widget build(BuildContext context) {
    return Text('Now playing: ${widget.audioFiles[currentIndex]["title"]}'); // Display the currently playing audioFile
  }
}



