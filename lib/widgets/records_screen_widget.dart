//todo implement real id

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../models/audio.dart';
import 'package:path/path.dart' as path;

import '../provider/record_list_provider.dart';


class RecordsListWidget extends StatefulWidget {
  @override
  _RecordsListWidgetState createState() => _RecordsListWidgetState();
}

class _RecordsListWidgetState extends State<RecordsListWidget> {
  //List<AudioFile> audioFiles = []; // Your list of audio files
  Audio? _currentAudioFile;
  //List<AudioFile> reorderedList = [];
  PlayerController _wavePlayer = PlayerController();
  String? _currentclientAppAudioFilePath;
  Widget? _waveformWidget;
  bool _isPlaying = false; // Add this variable

  bool _isInitialized = false;



    @override
  void initState() {
    super.initState();
/*    _loadAudioFiles();*/
  }





  void _playFile(String clientAppAudioFilePath) async {

    // Check if the same audioFile is already playing
    if (_currentclientAppAudioFilePath != clientAppAudioFilePath) {
      _startNewPlayer(clientAppAudioFilePath);
      return;
    }

    //If the file has not been finished
    if (!_wavePlayer.playerState.isStopped) {
      if (_isPlaying) {
        _wavePlayer.pausePlayer();
      } else{

        _wavePlayer.startPlayer();
      }
      setState(() {
        _isPlaying = _wavePlayer.playerState.isPaused; // Update the play/pause state
      });
      return;
    }
    _startNewPlayer(clientAppAudioFilePath);
  }

  void _startNewPlayer(String clientAppAudioFilePath) async{
    setState(() {
      _wavePlayer.dispose();
      _waveformWidget = null;
      _isPlaying = true; // Set the play state
    });

    _wavePlayer = PlayerController();

    _wavePlayer.updateFrequency = UpdateFrequency.high;

    await _wavePlayer.preparePlayer(
      path: clientAppAudioFilePath,
      shouldExtractWaveform: true,
      volume: 1.0,
    );

    setState(() {
      _currentclientAppAudioFilePath = clientAppAudioFilePath;
      _waveformWidget = AudioFileWaveforms(
        size: Size(MediaQuery.of(context).size.width, 100.0),
        playerController: _wavePlayer,
        enableSeekGesture: true,
        waveformType: WaveformType.long,
        playerWaveStyle: const PlayerWaveStyle(
          fixedWaveColor: Colors.white,
          liveWaveColor: Colors.deepPurple,
          spacing: 6,
        ),
      );
    });


    // Add a listener to the player's onPlayerFinish event
    _wavePlayer.onCompletion.listen((event) {
      setState(() {
        _isPlaying = false; // Reset the play state to false
      });
    });

    await _wavePlayer.startPlayer(finishMode: FinishMode.stop);
    setState(() {
      _isPlaying = _wavePlayer.playerState.isPlaying;
    });

  }

  void _deleteAudioFile(Audio audioFile) async {
    // Show confirmation dialog before deleting
    final shouldDelete = await _showDeleteConfirmationDialog(audioFile);
    if (!shouldDelete) return; // If user cancels, don't proceed with deletion

// Proceed with deletion
    var metadataBox = Hive.box<Audio>('audioMetadata');
    dynamic matchingKey;
    for (var key in metadataBox.keys) {
      Audio? existingAudioFile = metadataBox.get(key); // Directly get AudioFile
      if (existingAudioFile != null && existingAudioFile.title == audioFile.title) {
        matchingKey = key;
        break;
      }
    }

    if (matchingKey != null) {
      await metadataBox.delete(matchingKey);
      // Handle file deletion from the file system if necessary
    }

    if (matchingKey != null) {
      await metadataBox.delete(matchingKey);
      final file = File(audioFile.clientAppAudioFilePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Update UI
    setState(() {
      //audioFiles.remove(audioFile);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Audio file deleted')),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(Audio audioFile) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to remove this audio file?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirms deletion
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User cancels
              child: Text('No'),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed
  }



  @override
  Widget build(BuildContext context) {
    final audioListModel = Provider.of<RecordListProvider>(context);
    List<Audio> audioFiles = audioListModel.audioFiles;
    return ListView.builder(
        key: UniqueKey(),
      physics: NeverScrollableScrollPhysics(), // Disables scrolling within the ListView
      shrinkWrap: true, // Allows the ListView to size itself to its children
      itemCount: audioFiles.length,
      itemBuilder: (context, index) {
        return _buildAudioListItem(audioFiles[index]); // Replace with your actual widget
      },
    );
  }


  Widget _buildAudioListItem(Audio audioFile) {
    return Padding(
      padding: const EdgeInsets.all(10),
      key: ValueKey(audioFile.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.deepPurple,
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple,
              blurRadius: 3.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: _buildAudioFileRow(audioFile),
        ),
      ),
    );
  }

  Widget _buildAudioFileRow(Audio audioFile) {
    return Row(
      children: [
        // Play/Pause Button
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: _currentclientAppAudioFilePath == audioFile.clientAppAudioFilePath
                  ? (_isPlaying
                  ? const Icon(Icons.pause_circle_outline)
                  : const Icon(Icons.play_arrow))
                  : const Icon(Icons.play_arrow),
              color: Colors.deepPurple,
              iconSize: 30,
              onPressed: () {
                _playFile(audioFile.clientAppAudioFilePath);
              },
            ),
          ),
        ),
        const SizedBox(width: 12.0),

        // Audio Title
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurple),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: audioFile.title.length > 15 // Customize based on your desired length
                      ? Marquee(
                    text: audioFile.title,
                    style: const TextStyle(fontSize: 16.0),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 20.0,
                    velocity: 20.0,
                    startPadding: 10.0,
                  )
                      : Text(
                    audioFile.title,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8.0),

        // Duration
        Text(
          audioFile.duration.toString() + ' s',
          style: const TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        const SizedBox(width: 4.0),

        // Delete Button
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 0.0001,
              onPressed: () {
                _deleteAudioFile(audioFile);
              },
              icon: const Icon(Icons.delete),
              color: Colors.deepPurple,
            ),
          ),
        ),
      ],
    );
  }

// Additional helper methods...
}
