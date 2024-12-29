// Filename: join_page.dart

// This code represents the "JoinPage" class in a Flutter application.
// In this class, users can play and manage a list of audio files.
// Additionally, users can now add a description for the whole mix and for each individual audio file.
//todo add a slider for the files
//todo change play to pause button when playing
//todo use updateAudioDescription from AudioListProvider to update the audio description
//todo take care about duplications after it was implemented by prepare join
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:self_code/models/composition.dart';
import 'package:self_code/models/composition_audio.dart';

import '../models/audio.dart';
import '../provider/audio_list_provider.dart';
import '../provider/record_list_provider.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({Key? key}) : super(key: key);

  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final TextEditingController _listDescriptionController = TextEditingController();
  final TextEditingController _listTitleController = TextEditingController();
  List<TextEditingController> tagControllers = [];
  final TextEditingController _listTagController = TextEditingController();
  List<Map<String, dynamic>> _audioFileList = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _progress = 0.0;
  Timer? _progressTimer;
  bool _isDurationAvailable = false;

  @override
  void initState() {
    super.initState();
    _listTagController.text = '';
    _initPlayer();

    // Initialize the audio list from the provider
    _updateAudioFileListFromProvider();

    // Add listener to mix description controller
    _listDescriptionController.addListener(() {
      final audioListProvider = Provider.of<AudioListProvider>(context, listen: false);
      audioListProvider.setListDescription(_listDescriptionController.text);
    });
    _listTitleController.addListener(() {
      final audioListProvider = Provider.of<AudioListProvider>(context, listen: false);
      audioListProvider.setListTitle(_listTitleController.text);
    });



  }
  @override
  void dispose() {
    _listTagController.clear();
    _listTitleController.removeListener(() {
      // This is the body of your listener from above
    });
    _listTitleController.dispose();
    _listDescriptionController.removeListener(() {
      // This is the body of your listener from above
    });
    _listDescriptionController.dispose();
    _audioPlayer.dispose();
    _progressTimer?.cancel();
    _listTagController.dispose();
    super.dispose();
  }
// Load audio files from the provider
  void _updateAudioFileListFromProvider() {
    final audioListProvider = Provider.of<AudioListProvider>(context, listen: false);
    _audioFileList = audioListProvider.compositionAudios.map((compAudio) {
      final controller = TextEditingController(text: compAudio.content.description ?? "");
      _audioDescriptionControllers.add(controller);


      return {
        'id': compAudio.content.id,
        'title': compAudio.content.title,
        'description': compAudio.content.description ?? "",
        'repetition': compAudio.audioRepetition,
        //'clientAppAudioFilePath': compAudio.content.clientAppAudioFilePath,
        'duration': compAudio.content.duration,
        'tags': compAudio.content.tags ?? [],
      };

    }).toList();
    _listDescriptionController.text = audioListProvider.listDescription;
    _listTitleController.text = audioListProvider.listTitle;
  }

  void _initPlayer() {
    _audioPlayer = AudioPlayer();
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (_) async {
      // Check if the audio is not playing
      if (!_isPlaying) return;

      final currentPosition = await _audioPlayer.position;
      final totalDuration = _calculateTotalDuration();

      final isDurationAvailable = totalDuration != null && totalDuration.inMilliseconds > 0;

      if (isDurationAvailable) {
        setState(() {
          _isDurationAvailable = true;
          _progress = (currentPosition.inMilliseconds.toDouble() / totalDuration.inMilliseconds.toDouble()).clamp(0.0, 1.0);
          print('JoinPage: _initPlayer: _progress $_progress');
        });
      }
    });

  }

  Duration? _calculateTotalDuration() {
    if (_audioFileList.isEmpty) return null;

    final totalDuration = _audioFileList.fold<Duration>(
      Duration.zero,
          (previous, audioFile) => previous + Duration(milliseconds: audioFile.length)
    );

    return totalDuration;
  }

  Future<void> _playFile(String clientAppAudioFilePath) async {
    await _audioPlayer.setFilePath(clientAppAudioFilePath);
    await _audioPlayer.play();
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _seekToPosition(double value) async {
    final totalDuration = _calculateTotalDuration();
    final position = (value * (totalDuration?.inMilliseconds?.toDouble() ?? 0.0)).toInt();
    await _audioPlayer.seek(Duration(milliseconds: position));
  }

  Future<void> _pausePlayer() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _stopPlayer() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _progress = 0.0;
    });
  }

  List<TextEditingController> _audioDescriptionControllers = [];


  Future<void> _playAllFiles() async {
    for (final compAudio in _audioFileList) {
      //final String clientAppAudioFilePath = compAudio['clientAppAudioFilePath'];
      final int repetition = compAudio['repetition'];

      for (int i = 0; i < repetition; i++) {
        //await _playFile(clientAppAudioFilePath);
        await Future.delayed(Duration(milliseconds: 100));
        await _stopPlayer();
        setState(() {});
      }
    }
  }

  int _calculateCurrentAudioFileIndex(Duration position) {
    int index = 0;
    Duration accumulatedDuration = Duration.zero;

    for (final audioFile in _audioFileList) {
      final audioFileDuration = audioFile['duration'] as Duration;
      accumulatedDuration += audioFileDuration;

      if (position <= accumulatedDuration) {
        return index;
      }

      index++;
    }

    return index;
  }

  @override
  Widget build(BuildContext context) {
    final audioListProvider = Provider.of<AudioListProvider>(context, listen: true);
    final compFiles = audioListProvider.getCompositionAudios;
    final tags = audioListProvider.listTags; // Correct property access

    return Scaffold(
      //backgroundColor: Colors.deepPurple,
      backgroundColor: Colors.grey.shade900,


    appBar: AppBar(
        title: const Text('Join Page'),
      actions: [ IconButton(
        icon: Icon(Icons.save_rounded),
        onPressed: () {
          final fileName = _listTitleController.text.trim();
          if (fileName.isNotEmpty) {
            Navigator.pushNamed(context, '/after_join');
            //audioListProvider.saveAudioListAsJson(fileName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter a valid Composition name.')),
            );
          }
        },
      ),],
      backgroundColor: Colors.transparent,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(
            color: Colors.white,  // Choose your desired color here
          ),
          inputDecorationTheme: InputDecorationTheme(
helperStyle: TextStyle(color: Colors.black),
            focusColor: Colors.black,
            hoverColor: Colors.black,
            fillColor: Colors.deepPurple,
            filled: true,
            // This sets the focused border to green
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2.0),
            ),
            // This sets the default border color to green
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2.0),
            ),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Set Composition name:', style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 5,),
            Column(
              
              children: [
                Row(
                  children: [

                    Expanded(
                      child: TextField(

                        controller: _listTitleController,
                        decoration: InputDecoration(
                          hintText: 'Enter Composition name',
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  ],
                ),
                    const SizedBox(height: 16.0),

            Align(alignment: Alignment.centerLeft,child: Text('Enter Composition description:', style: TextStyle(color: Colors.white, fontSize: 16,))),
            SizedBox(height: 5,),
            TextField(
              controller: _listDescriptionController,
              decoration: InputDecoration(
                hintText: 'Enter Composition description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16.0),
                Align(alignment: Alignment.centerLeft,
                  child: Text('Add Tag for Entire List:',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),

                // Description: Widget for entering a tag and adding it to the list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _listTagController,
                          decoration: InputDecoration(
                            hintText: 'Enter tag for list',
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          final tag = _listTagController.text.trim();
                          if (tag.isNotEmpty) {
                            audioListProvider.addTagToList(tag);
                            _listTagController.clear();
                            setState(() {}); // Refresh UI
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please enter a valid tag.')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),


                (tags.isNotEmpty && tags.any((tag) => tag.isNotEmpty))
                    ? Wrap(
                  children: tags.where((tag) => tag.isNotEmpty).map((tag) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Chip(
                        backgroundColor: Colors.deepPurple,
                        label: Text(tag, style: TextStyle(color: Colors.greenAccent)),
                        deleteIcon: Icon(Icons.close, size: 18.0, color: Colors.white),
                        onDeleted: () {
                          audioListProvider.removeTagFromList(tag);
                          setState(() {}); // Refresh UI
                        },
                      ),
                    );
                  }).toList(),
                )
                    : Container()


              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (!_isPlaying) {
                  _playAllFiles();
                } else {
                  _pausePlayer();
                }
              },
              child: Text(_isPlaying ? 'Pause' : 'Play All'),
            ),
            if (_isDurationAvailable)
              Slider(
                value: _progress,
                onChanged: (value) {
                  _seekToPosition(value);
                  setState(() {
                    _progress = value;
                  });
                },
              ),

            const SizedBox(height: 16.0),
            Text('Enter Subtitles / Description for each file:', style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 5,),
            ...compFiles.asMap().entries.map((entry) {
              int index = entry.key;
              CompositionAudio compAudio = entry.value;
              tagControllers.add(TextEditingController());
      return Card(
        margin: EdgeInsets.only(bottom: 20),
        color: Colors.deepPurple,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
              title: Text(compAudio.content.title, style: TextStyle(color: Colors.white)),
              trailing: ElevatedButton(
                onPressed: () =>
                    //_playFile(audio.clientAppAudioFilePath)
                print(''),
                child: Text('Play', style: TextStyle(color: Colors.white)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Enter Audio description:',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  SizedBox(height: 5,),
                  TextField(
                    controller: compAudio.content.descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Enter description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Add Tags:',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.only(left: 18, bottom: 18),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tagControllers[index],
                      decoration: InputDecoration(
                        hintText: 'Enter tag',
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      final tag = tagControllers[index].text.trim();
                      print(tag);
                      if (tag.isNotEmpty) {
                        audioListProvider.addTagToFileById(
                            compAudio.content.id,
                            tag); // New method in provider to add a tag for a specific audio
                        tagControllers[index].clear();
                        setState(() {}); // Refresh UI
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a valid tag.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Wrap(
              children: compAudio.content.tags.map<Widget>((tag) {
                print('wrap: $tag'); // Assume each audioFile has a tags list
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Chip(backgroundColor: Colors.deepPurple,
                    label: Text(
                        tag, style: TextStyle(color: Colors.greenAccent)),
                    deleteIcon: Icon(
                        Icons.close, size: 18.0, color: Colors.black87),
                    onDeleted: () {
                      audioListProvider.removeTagFromFileById(compAudio.compositionAudioId,
                          tag); // New method in provider to remove a tag from a specific audio
                      setState(() {}); // Refresh UI
                    },
                  ),
                );
              }).toList(),
            ),

          ],
        ),
      );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
