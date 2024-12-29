//todo stop audio when leave the screen
//todo determine and mark duplications
//todo add username to composition
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:self_code/models/composition_audio.dart';
import 'package:self_code/widgets/common_bottom_navigation_bar.dart';
import 'package:uuid/uuid.dart';
import '../models/composition.dart';
import '../provider/audio_list_provider.dart';
import '../presenatation/my_flutter_app_icons.dart';
import 'local_file_page.dart';
import 'dart:convert';
//import of models
import 'package:self_code/models/audio.dart';

List<Map<String, dynamic>> _audioFileList = [];

class AudioFileListScreen extends StatefulWidget {
  const AudioFileListScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _AudioFileListScreenState createState() => _AudioFileListScreenState();
}

class _AudioFileListScreenState extends State<AudioFileListScreen> {
  //List<AudioFile> reorderedList = [];
  PlayerController _wavePlayer = PlayerController();
  String? _currentclientAppAudioFilePath;
  Widget? _waveformWidget;
  bool _isPlaying = false; // Add this variable

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // This ensures that the initialization is only done once
    if (!_isInitialized) {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _wavePlayer.stopAllPlayers();
    _wavePlayer.dispose();
    super.dispose();
  }




  Future<void> _getAudioDuration(Audio audioFile) async {
    final player = PlayerController();

    try {
      await player.preparePlayer(
        path: audioFile.clientAppAudioFilePath,
        shouldExtractWaveform: true,
      );

      final duration = await player.getDuration(DurationType.max);

      setState(() {
        audioFile.duration = duration ~/ 1000;
        audioFile.durationInMilliseconds = duration;
      });

      // Add the audioFile with duration to the JSON list
      final audioFileWithDuration = {
        'title': audioFile.title,
        'clientAppAudioFilePath': audioFile.clientAppAudioFilePath,
        'duration': audioFile.duration,
        'durationMilliseconds': audioFile.durationInMilliseconds,
      };
      _audioFileList.add(audioFileWithDuration);
    } catch (e) {
      // Handle any errors that occur during duration retrieval
      print('Error retrieving duration: $e');
    } finally {
      player.dispose();
    }
  }




  void _addFile() async {
    final audioListProvider = Provider.of<AudioListProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add File'),
          content: Text('Choose the source of the file'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                FilePickerResult? result =
                await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: {'mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg', 'wma'}.toList(),
                );
                if (result != null) {
                  String? filePath = result.files.single.path;
                  if (filePath != null) {
                    _addFileToList(filePath);
                  }
                }
              },
              child: Text('From Device'),
            ),
            TextButton(
              onPressed: () async {
                dynamic selectedFileOrComposition = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocalFilesPage(),
                  ),
                );

                if (selectedFileOrComposition is Audio) {
                  // Handle as AudioFile
                  Audio audioFile = selectedFileOrComposition;
                  await _getAudioDuration(audioFile); // Calculate the duration for the audioFile
                  audioListProvider.addCompositionAudio(audioFile, 0,1); // Adjust this method to accept CompositionAudio
                  print('_addFile audioFile add');
                } else if (selectedFileOrComposition is Composition) {
                  // Handle as Composition
                  Composition composition = selectedFileOrComposition;
                  print("selectedFileOrComposition.id: ${selectedFileOrComposition.id}");
                  for (CompositionAudio file in selectedFileOrComposition.compositionAudios){
                    print("selectedFileOrComposition.compositionAudio: ${file.content.id}");
                  }

                  audioListProvider.addCompositionAudio(composition, 0 ,1); // Adjust this method to accept CompositionAudio
                  print('_addFile composition add');
                } else {
                  // Handle error or unexpected type
                  print("Unknown type returned from LocalFilesPage");
                }

                Navigator.of(context).pop();


              },
              child: Text('From App'),
            ),

          ],
        );
      },
    );
  }

  void _addFileToList(String filePath) async {
    final audioListProvider = Provider.of<AudioListProvider>(context, listen: false);
    final file = File(filePath);
    final extension = path.extension(file.path).toLowerCase();
    if (extension == '.mp3' ||
        extension == '.wav' ||
        extension == '.aac' ||
        extension == '.m4a' ||
        extension == '.flac' ||
        extension == '.ogg' ||
        extension == '.wma') {
      final audioFile = Audio(
        id: Uuid().v4(),
        title: path.basenameWithoutExtension(file.path),
        clientAppAudioFilePath: file.path,
      );

      await _getAudioDuration(audioFile); // Wait for the duration to be retrieved

      setState(() {
        audioListProvider.addCompositionAudio(audioFile, 0, 1); // Default position and repetition
        updateAudioFileList();
      });
    }
  }

  void updateAudioFileList() {
    final audioListProvider = Provider.of<AudioListProvider>(context, listen: false);

    _audioFileList = audioListProvider.getCompositionAudios.map((compContent) {
      if (compContent.content is Audio) {
        Audio audio = compContent.content;
        return {
          'title': audio.title,
          'repetition': compContent.audioRepetition,
          'clientAppAudioFilePath': audio.clientAppAudioFilePath,
          'duration': audio.duration,
          'durationMilliseconds': audio.durationInMilliseconds,
          'audioPosition': compContent.audioPosition
        };
      }
      // Return a map with the same keys but null or default values
      return {
        'title': null,
        'repetition': null,
        'clientAppAudioFilePath': null,
        'duration': null,
        'durationMilliseconds': null,
        'audioPosition': null
      };
    }).toList().cast<Map<String, dynamic>>(); // Cast the list to the correct type
  }

  void _updateRepetition(CompositionAudio compAudio, String newValue) {
    final newRepetition = int.tryParse(newValue) ?? compAudio.audioRepetition; // Default to current value on parse failure
    final audioListProvider = Provider.of<AudioListProvider>(context, listen: false);

    // Update the repetition using the existing method in the provider
    audioListProvider.updateCompositionAudio(compAudio.compositionAudioId, compAudio.audioPosition, newRepetition);

    // Refresh the local _audioFileList to reflect changes
    updateAudioFileList();
  }





  Future<void> _removeAudioFileFromList(dynamic compAudio) async {
    bool userChoice = await confirmation(context);
    final audioListProvider = Provider.of<AudioListProvider>(context, listen: false);

    if (userChoice) {
      // Find the ID of the CompositionAudio that contains the given AudioFile
// Before the loop, ensure compAudio is also a CompositionAudio to access its id safely.
      if (compAudio is CompositionAudio) {
        for (var compContent in audioListProvider.getCompositionAudios) {
          print('compContent.id: ${compContent.compositionAudioId}, compAudio.id: ${compAudio.compositionAudioId}');
          if (compContent is CompositionAudio && compContent.compositionAudioId == compAudio.compositionAudioId) {
            // If a matching CompositionAudio is found, remove it using its ID
            setState(() {
              audioListProvider.removeCompositionAudio(compContent.compositionAudioId);
              updateAudioFileList();
            });
            break; // Exit the loop once the match is found
          }
        }
      }

    }
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

  Future<bool> confirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to remove this audioFile from the mix?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed without pressing any buttons
  }

  Future<void> _clearAudioList(AudioListProvider audioListProvider) async {
    bool userChoice = await confirmation(context);
    if (userChoice){
      setState(() {
        audioListProvider.clearList();
        // Call to update your audio file list if needed
        // updateAudioFileList(); // Uncomment if necessary
      });
      return;
    } else{
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioListProvider = Provider.of<AudioListProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final itemHeight = 90.0; // Adjust this value based on your item height
    print(screenHeight);
    final maxVisibleItems = (screenHeight -60) ~/ itemHeight;
    bool isScrollable = audioListProvider.compositionAudios.length > maxVisibleItems;
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Mix your mind sounds'),//Text(widget.title),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Remove all', style: TextStyle(color: Colors.white)),  // Assuming your AppBar is dark
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.white),  // Assuming your AppBar is dark
                onPressed: () {
                  _clearAudioList(audioListProvider);
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView(
              buildDefaultDragHandles: false,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final compContent = audioListProvider.compositionAudios.removeAt(oldIndex);
                  audioListProvider.compositionAudios.insert(newIndex, compContent);
                  audioListProvider.notifyListeners();
                  updateAudioFileList();
                });
              },
              children: <Widget>[
                for (final compContent in audioListProvider.compositionAudios)
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                    key: ValueKey(compContent.compositionAudioId),
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
                      child: ReorderableDragStartListener(
                        key: ValueKey(compContent),
                        index: audioListProvider.compositionAudios.indexOf(compContent),
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(0.02 * audioListProvider.compositionAudios.indexOf(compContent)), // Adjust the rotation angle as desired
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
                              key: ValueKey(compContent),
                              title: Row(
                                children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                                child: Center(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: /*_currentclientAppAudioFilePath == compContent.content.clientAppAudioFilePath
                                        ? (_isPlaying
                                        ? const Icon(Icons.pause_circle_outline)
                                        : const Icon(Icons.play_arrow))
                                        : */const Icon(Icons.play_arrow),
                                    color: Colors.deepPurple,
                                    iconSize: 30,
                                    onPressed: () {
                                      //_playFile(compContent.content.clientAppAudioFilePath);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),

                              GestureDetector(
                                onTap: () {
                                  _showRepetitionDialog(compContent);
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5), color: Colors.white),
                                  child: Center(
                                    child: Text(
                                      '${compContent.audioRepetition}x',
                                      style: const TextStyle(fontSize: 16.0, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                                    ),

                                  ),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                                  height: 40,
                                  decoration: BoxDecoration( border: Border.all(color: Colors.deepPurple),
                                      color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 4.0),
                                      Container(
                                        width: 100,
                                        child: compContent.content.title.length > 15 // Customize the condition based on your desired length
                                            ? Marquee(
                                          text: compContent.content.title,

                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                          scrollAxis: Axis.horizontal,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          blankSpace: 20.0,
                                          velocity: 20.0,
                                          startPadding: 10.0,
                                        )
                                            : Text(
                                          compContent.content.title,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        compContent.content.duration.toString() + ' s',
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(width: 4.0),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Icon(MyFlutterApp.icon_drag_drop_list,color: Colors.white,),
                              const SizedBox(width: 4.0),
                              Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(15 )),
                                child: Center(
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    splashRadius: 0.0001,
                                    onPressed: () {
                                      _removeAudioFileFromList(compContent);
                                    },
                                    //icon: Icon(Icons.close),
                                    icon: Icon(Icons.remove_circle_outline , ),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ),
                      ),
                    ),
                  ),
                    ),
                  ),
        ],
            ),
          ),
          if (isScrollable) // Add the note only if the screen is scrollable
            Padding(
              padding: const EdgeInsets.only(top: 8,bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[ Text(
                  'Scroll with two fingers',
                  style: TextStyle(fontSize: 14.0, color: Colors.deepPurple),
                ),
                  Icon(Icons.fingerprint, color: Colors.white,),
                  Icon(Icons.fingerprint, color: Colors.white,),
                ]
              ),
            ),
          SizedBox(height: 8.0),
          FloatingActionButton.extended(
            heroTag: '1',
            onPressed: _addFile,
            label: Text(
              'Add File',
              style: TextStyle(fontSize: 16.0),
            ),
            icon: Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16.0),
          if (_waveformWidget != null) _waveformWidget!,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: '2',
        onPressed: () {
          final jsonString = jsonEncode(_audioFileList);
          Navigator.pushNamed(context, '/join', arguments: jsonString);
        },
        tooltip: 'Save',
        child: const Icon(Icons.save_rounded),
      ),
    );
  }

  void _showRepetitionDialog(CompositionAudio compAudio) {
    final TextEditingController repetitionController = TextEditingController(text: compAudio.audioRepetition.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Repetition Count'),
          content: TextField(
            controller: repetitionController,
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              _updateRepetition(compAudio, value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateRepetition(compAudio, repetitionController.text);
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}


