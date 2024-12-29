//todo add pause player
//todo issue when click to fast record / stop and then no wave when click play
//todo make sure default will be stored in another folder so that the list is not calling it? Maybe even better push the files in another folder in general..
//todo implement hive to store meta data
//todo check django issue: TypeError: View.__init__() takes 1 positional argument but 2 were given
//todo play wave should not immediately on stop overlay the record wave otherwise it seems there was nothing recoded
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
//For additional permission config:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:self_code/provider/user_data_provider.dart';
import 'package:self_code/widgets/common_bottom_navigation_bar.dart';

import '../api/api_audio.dart';
import '../models/audio.dart';
import '../provider/single_audio_provider.dart';
import '../widgets/records_screen_widget.dart';


class AudioRecorder extends StatefulWidget {
  const AudioRecorder({super.key});


  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  TextEditingController _filenameController = TextEditingController();
  List<FileSystemEntity> _files = [];
  late final PlayerController _wavePlayer = PlayerController();
  late RecorderController _recorderController = RecorderController();
  String _filePath = '';
  bool _isRecording = false;
  bool _isPlaying = false;
  bool audioFinished = false;
  bool _recordDone = false;
  @override
  void initState() {
    super.initState();
    initDirectory();
    _init();
  }



  @override
  void dispose(){
    _wavePlayer.stopAllPlayers();
    _wavePlayer.dispose();
    super.dispose();
  }

  void initDirectory() async{
    String relativePath = '/audio';
    String defaultPath = getLocalPath() as String;
    String targetPath = defaultPath+relativePath;
    print('targetPath: $targetPath');
    await ensureDirectoryExists(targetPath);
  }
  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<void> ensureDirectoryExists(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);  // Using recursive: true ensures that all non-existing intermediate directories are also created.
    }
  }

// Usage:


  Future<void> _init() async {
    _showFilesInDirectory();
    await _wavePlayer.preparePlayer(
      path: _filePath,
      shouldExtractWaveform: true,
      volume: 1.0,
    );
    _wavePlayer.onCompletion.listen((_){
      setState(() {
        _isPlaying = false;
        _wavePlayer.stopPlayer();
        audioFinished = true;
        print('____________Listener Player Completed____________');
      });

    });

  }


  Future<void> _requestPermission() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      Fluttertoast.showToast(
        msg: 'Microphone permission is required for recording.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _record() async {
    final audioProvider = Provider.of<SingleAudioProvider>(context, listen: false);

    // If currently recording, stop and return.
    if (_isRecording) {
      print('stop recording');
      await _stopRecording();
      return; // Exit method here.
    }

    // If currently playing, pause and set _isPlaying to false.
    if (_isPlaying) {
      await _pausePlayer();
    }

    PermissionStatus status = await Permission.microphone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await _requestPermission();
      return;
    }
   // _init();
    if (status.isGranted || status.isLimited) {

      setState(() {
        _isRecording = true;
      });
      _recorderController.reset();
      await _startRecording();
    }
  }




  Future<void> _startRecording() async {
    _filePath = '${(await getApplicationDocumentsDirectory()).path}/default.aac';

    await _recorderController.record(
      path: _filePath,
      androidEncoder: AndroidEncoder.aac,
      bitRate: 128000,
      sampleRate: 96000,
    );
  }






  Future<void> _stopRecording() async {
    final audioProvider = Provider.of<SingleAudioProvider>(context, listen: false);
    if (!_isRecording) {
      print('is not recording');
      return;
    }

    _filePath = '${(await getApplicationDocumentsDirectory()).path}/default.aac';
    await _recorderController.stop(false);

    setState(() {
      _isRecording = false;
      _recordDone = true;
    });

    _showFilesInDirectory();

    _wavePlayer.stopPlayer();
    await _wavePlayer.preparePlayer(
      path: _filePath,
      shouldExtractWaveform: true,
      volume: 1.0,
    );

    _wavePlayer.onCompletion.listen((_) {
      setState(() {
        _isPlaying = false;
        _wavePlayer.stopPlayer();
        audioFinished = false;
        print('____________Listener Player Completed____________');
      });
    });
    audioFinished = true;
  }


  Future<void> _play() async {
    _recorderController.reset();
    print('_play');
    if (_isRecording) {
      await _stopRecording();
      // Do not return; proceed to the play logic.
    }

    if (_isPlaying) {
      print('_play _isPlaying = true --> _pausePlayer');
      await _pausePlayer();
      return;
    }
    print('_play, filePath: $_filePath');
    if (_filePath.isNotEmpty) {
      setState(() {
        _isPlaying = true;
      });
      print('start playing with source $_filePath' );
/*      _wavePlayer.onCompletion.listen((_){    setState(() {
        _wavePlayer.pausePlayer();
        _isPlaying = false;
      });});*/
      if (!audioFinished) {
        await _wavePlayer.preparePlayer(
          path: _filePath,
          shouldExtractWaveform: true,
          volume: 1.0,
        );
        _wavePlayer.onCompletion.listen((_) {
          setState(() {
            _isPlaying = false;
            _wavePlayer.stopPlayer();
            audioFinished = false;
            print('____________Listener Player Completed____________');
          });
        });
        audioFinished = true;
      }
      await _wavePlayer.startPlayer(finishMode: FinishMode.stop);
    } else {
      // If there's no valid _filePath, you can show an error message or handle it accordingly.
      Fluttertoast.showToast(
        msg: 'No audio file to play.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }



  Future<void> _pausePlayer() async {

    setState(() {
      _isPlaying = false;
    });
    await _wavePlayer.pausePlayer();

  }




  void storeFileInfoInProvider(String path) {
    final audioProvider = Provider.of<SingleAudioProvider>(context, listen: false);
    audioProvider.audioFile = Audio(
      clientAppAudioFilePath: path,
      title: '',
      //... other initializations ...
    );
  }



  // This method is responsible for showing files in a directory and sorts them in descending order by their last modified date.
  void _showFilesInDirectory() async {
    _files.clear(); // Clear the list first
    final dirPath = '${(await getApplicationDocumentsDirectory()).path}/audio';
    final Directory directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(); // This will create the directory if it doesn't exist
    }
    List<FileSystemEntity> allFiles = [];

    await for (FileSystemEntity entity in directory.list(recursive: false)) {
      if (FileSystemEntity.typeSync(entity.path) == FileSystemEntityType.file) {
        allFiles.add(entity);
      }
    }

    _files.sort((a, b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
    print("Sorted Files: ${_files.map((file) => File(file.path).lastModifiedSync().toString()).toList()}");
    setState(() {
      _files = allFiles;
    });
    _files.sort((a, b) {
      return b.statSync().modified.compareTo(a.statSync().modified); // using b first for descending order
    });
  }

  Future<bool> saveFile(BuildContext context) async {
    if (_isRecording) {
      await _stopRecording();
      // Do not return; proceed to the play logic.
    }

    final audioProvider = Provider.of<SingleAudioProvider>(context, listen: false);
    final fileName = audioProvider.audioTitleController.text.trim();
    if (fileName.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid filename.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
    final path = await getLocalPath();
    final newPath = '${(await getApplicationDocumentsDirectory()).path}/audio/';
    final Directory directory = Directory(newPath);
    if (!await directory.exists()) {
      await directory.create(); // This will create the directory if it doesn't exist
    }
    final defaultFilePath = '$path/default.aac';
    final defaultFile = File(defaultFilePath);
    final newFilePath = '$newPath/$fileName.aac';
    final file = File(newFilePath);
    if (await file.exists()) {
      // File already exists. Prompt the user.
      bool overwrite = await _confirmOverwrite(context);
      if (!overwrite) {
        return false;
      }
    }
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final user = userDataProvider.currentUser;
    final userName = user?.username ?? 'noUser';
    await defaultFile.copy(newFilePath);
    _showFilesInDirectory();
    Audio audioFile = Audio(
      title: fileName,
      description : '', //This string will be filled from text field if used.
      clientAppAudioFilePath: newFilePath,
      duration : _recorderController.recordedDuration.inSeconds.toInt(),
      durationInMilliseconds: _recorderController.recordedDuration.inMilliseconds.toInt(),
      username: userName,
      userTimeStamp: DateTime.now().toUtc().toString(),
    );
    // Save metadata using Hive
    bool uploadSuccess = await saveOrUpdateHiveAudioMeta(audioFile);
    // After saving file and metadata locally, send them to the backend

    setState(() {
    });
    _showFilesInDirectory();
    await _uploadMusic(file, fileName);

    return uploadSuccess;
  }

  Future<bool> saveOrUpdateHiveAudioMeta(Audio newAudioFile) async {
    var metadataBox = Hive.box<Audio>('audioMetadata');

    // Find the key for the entry with the matching title
    dynamic matchingKey;
    for (var key in metadataBox.keys) {
      Audio? existingAudioFile = metadataBox.get(key); // Directly get AudioFile
      if (existingAudioFile != null && existingAudioFile.title == newAudioFile.title) {
        matchingKey = key;
        break;
      }
    }

    if (matchingKey != null) {
      // Update the existing entry
      await metadataBox.put(matchingKey, newAudioFile);
    } else {
      // Add a new entry with a new UUID
      await metadataBox.put(newAudioFile.id, newAudioFile);
    }

    // Debugging: Print all entries
    metadataBox.values.forEach((audioFile) {
      print(audioFile); // Directly print AudioFile objects
    });
    return true;
  }




  Future<bool> _uploadMusic(File file, String fileName) async {
    print('uploading music...');
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final user = userDataProvider.currentUser;
    final userName = user?.username ?? 'noUser';
    bool success = false;
    ApiAudio musicApi = ApiAudio();
    await musicApi.uploadMusic(
      musicFile: file,
      userName: userName,
      customFileName: fileName,
      tags: [],
      onProgress: (double progress) {
        setState(() {
          print('uploading $progress%');
        });
      },
      onSuccess: () {
        success = true;
      },
      onError: (String errorMessage) {
        success = false;
        print(errorMessage); // You can display this error message to the user if needed
      },
    );
    return success;
  }




  Future<bool> _confirmOverwrite(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('File Exists'),
            content: Text('A file with the same name already exists. Do you want to overwrite it?'),
            actions: <Widget>[
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);  // Dismiss the dialog and return false
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);  // Dismiss the dialog and return true
                },
              ),
            ],
          );
        }
    ) ?? false;  // Return false if the user dismisses the dialog without choosing any option
  }

  void saveAndPostFile() {
    //saveFile();
    // Logic to post the file after saving goes here
  }


  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<SingleAudioProvider>(context);

    return Scaffold(
        //backgroundColor: Colors.grey.shade900,
        backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Audio Recorder'),
        backgroundColor: Colors.transparent,
      ),
      body: Theme(
    data: Theme.of(context).copyWith(
    iconTheme: IconThemeData(
    color: Colors.white,  // Choose your desired color here
    ),
    inputDecorationTheme: InputDecorationTheme(

    fillColor: Colors.white,
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
    child:
      SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,

                  ),
                  SizedBox(height: 5,),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(alignment: Alignment.centerLeft,
                            child: Text('Set File Name', style: TextStyle(color: Colors.white, fontSize: 16))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: audioProvider.audioTitleController,
                          decoration: InputDecoration(
                            hintText: 'Enter File Name',
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),

                    ],
                  ),



                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: AudioWaveforms(
                          size: Size(MediaQuery.of(context).size.width, 50.0),
                          recorderController: _recorderController,
                          backgroundColor: Colors.transparent,
                          enableGesture: true,
                            shouldCalculateScrolledPosition: false,
                          padding: EdgeInsets.only(bottom: 0),
                          waveStyle: const WaveStyle(
                            waveColor: Colors.white,
                            waveThickness: 3,
                            durationStyle: TextStyle(color: Colors.white, fontSize: 16),
                            durationLinesColor: Colors.white,
                            showDurationLabel: true,
                            durationLinesHeight: 10,
                            waveCap: StrokeCap.round,
                            durationTextPadding: -4,
                            extraClipperHeight: 40,
                            spacing: 20.0,
                            showBottom: true,
                            bottomPadding: 25,
                            extendWaveform: true,
                            showMiddleLine: false,
                            scaleFactor: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 0,),
                      Visibility(
                        visible: !_isRecording,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: AudioFileWaveforms(
                            backgroundColor: Colors.transparent,
                            decoration: BoxDecoration(color: Colors.transparent),
                            size: Size(MediaQuery.of(context).size.width, 50.0),
                            playerController: _wavePlayer,
                            enableSeekGesture: true,
                            waveformType: WaveformType.long,
                            animationDuration: Duration(milliseconds: 10000),
                            animationCurve: Curves.linear,

                            playerWaveStyle: const PlayerWaveStyle(
                              seekLineThickness: 3,
                              scaleFactor: 100,
                              seekLineColor: Colors.deepPurple,
                              backgroundColor: Colors.deepPurple,
                              fixedWaveColor: Colors.transparent,
                              liveWaveColor: Colors.white,
                              spacing: 6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 0,
              height: 40,
            ),
            // Filename input box
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15.0))),
              onPressed: _record,
              child: Column(children: [
                Icon(_isRecording ? Icons.stop : Icons.mic_none_rounded, size: 80, color: Colors.white,),
                Text(_isRecording ? 'Stop' : 'Record')],),
            ),
              ElevatedButton(
                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15.0))),
                onPressed: _play,
                child: Column(children: [
                  Icon(_isPlaying ? Icons.pause : Icons.play_arrow_outlined , size: 80,color: Colors.white,),
                  Text(_isPlaying ? 'Pause' : 'Play')],),
              ),


                   if(_recordDone)
              ElevatedButton(
                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15.0))),
                onPressed: () async{
                  bool success = await saveFile(context);
                  Color resultColor;
                  String result;
                  if(success) {
                    result="File saved successfully";
                    resultColor = Colors.greenAccent;
                  } else {
                    result="File saving cancelled";
                    resultColor = Colors.red;
                  }
                  Fluttertoast.showToast(
                    backgroundColor: resultColor,
                    msg: '$result',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.SNACKBAR,
                  );
                },
                child: Column(children: [
                  Icon(Icons.save,size: 80, color: Colors.white,),
                  Text('Save / Overwrite'),

                ]


                    ,),
                ),
              ],),
            SizedBox(height: 20,),
            Text('Recently recorded', style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 20,),
            RecordsListWidget(),
          ]
        ),
      ),
    )
    );

  }
}
