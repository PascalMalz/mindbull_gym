import 'package:flutter/material.dart';
import 'package:self_code/widgets/common_sound_progress_bar.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartAProgram extends StatefulWidget {
  const StartAProgram({Key? key}) : super(key: key);

  @override
  StartAProgramState createState() => StartAProgramState();
}

class StartAProgramState extends State<StartAProgram> {

  @override
  void initState() {
    super.initState();
    initJson();


  }

  List<Map<String, dynamic>> jsonData = [];
  Duration totalDuration = Duration.zero;
  bool running = false;
  bool isPlaying = false;
  String currentAudioFileTitle = '';
  Duration currentAudioFileDuration = Duration.zero;
  num lengthOfPreviousAudioFiles = 0;
  int filesInJsonData = 0;
  int iteration = 0;
  Duration currentSeekPosition = Duration.zero;
  bool releasedToPlay = true;
  String selectedFile = "";


  final player = AudioPlayer(); // Initialize the player variable

  initJson() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String currentRefreshToken = prefs.getString('refreshToken') ?? '';
    print('StartAProgram: currentRefreshToken: $currentRefreshToken');
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync().whereType<File>().toList();
      final selectedJsonFile = files[1];
      print( "files123: $selectedJsonFile");
      final String jsonContent = await selectedJsonFile.readAsString();
      final List<dynamic> decodedJson = json.decode(jsonContent);
      setState(() {
        jsonData = decodedJson.cast<Map<String, dynamic>>();
        totalDuration = calculateTotalDuration(jsonData);
      });

    } catch (error) {
      // todo Handle error
    }

  }


  void _loadJsonData(String? selectedFile) async {

    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync().whereType<File>().toList();
      final selectedJsonFile = files.firstWhere((file) => file.path.endsWith(selectedFile!));
      final String jsonContent = await selectedJsonFile.readAsString();
      final List<dynamic> decodedJson = json.decode(jsonContent);
      setState(() {
        jsonData = decodedJson.cast<Map<String, dynamic>>();
        totalDuration = calculateTotalDuration(jsonData);
      });

    } catch (error) {
      // todo Handle error
    }
  }

  Duration calculateTotalDuration(List<Map<String, dynamic>> audioFiles) {
    Duration totalDuration = Duration.zero;
    for (final data in audioFiles) {
      final int? durationMilliseconds = data['durationMilliseconds'] * data['repetition'] as int? ;
      if (durationMilliseconds != null) {
        totalDuration += Duration(milliseconds: durationMilliseconds);
      }
    }
    return totalDuration;
  }
  void playAudioFilesConsecutively({seekIndex = 0, seekAbs = 0}) async {
    print('seekAbs: $seekAbs , seekAbs in min ${seekAbs/1000/60}');
    if (!releasedToPlay){

      seekAbs = currentSeekPosition.inMilliseconds;
      setState(() {
        isPlaying = true;
        releasedToPlay = true;
        running = true;
      });

    }
    running = false;
    releasedToPlay = true;
    lengthOfPreviousAudioFiles = 0; //todo Useless?
    bool seekNecessary = false;
    num lengthOfPreviousAudioFilesNew = 0;
    Duration seek = Duration.zero;
    int repetitionSeek = 0;

    if (seekAbs > 0) {
      iteration = 0;
      filesInJsonData = jsonData.length;
      num calculatedLength = 0;


        for (iteration; iteration < filesInJsonData; iteration++) {
          final audioFiles = jsonData[iteration];
          int iterationRepetition = 0;
          for (iterationRepetition; iterationRepetition < audioFiles['repetition']; iterationRepetition++) {
          calculatedLength = calculatedLength + audioFiles['durationMilliseconds'];

          if (calculatedLength >= seekAbs) {
            seekNecessary = true;
            lengthOfPreviousAudioFilesNew =
                calculatedLength - audioFiles['durationMilliseconds'];
            seek = Duration(
                milliseconds: (seekAbs - lengthOfPreviousAudioFilesNew).toInt());
            seekIndex = iteration;
            repetitionSeek = iterationRepetition;
            break;
          }

        }
          if (calculatedLength >= seekAbs){
            break;
          }
      }
    }
    print('seekindex: $seekIndex , seek in min ${seek.inSeconds/60}');
    await player.stop();
    if (jsonData.isNotEmpty) {
      setState(() {
        running = true;
      });

      filesInJsonData = jsonData.length;
      iteration = seekIndex;
      lengthOfPreviousAudioFiles = lengthOfPreviousAudioFilesNew;
      for (iteration; iteration < filesInJsonData; iteration++) {
        isPlaying = true;
        final audioFile = jsonData[iteration];
        int iterationRepetition = repetitionSeek;
        for (iterationRepetition; iterationRepetition < audioFile['repetition']; iterationRepetition++) {
          print('iterationRepetition: $iterationRepetition seekIndex: $seekIndex');
        if (!running ||
            !releasedToPlay) { //Needed for the scrollbar functionality
          break; // Stop playing audioFiles
        }

        if (running) {
          if (mounted) {
            setState(() {
              currentAudioFileTitle = audioFile['title'];
              currentAudioFileDuration = Duration(seconds: audioFile['duration']);
            });
          }

          final audioSource = AudioSource.uri(Uri.parse(audioFile['clientAppAudioFilePath']));
          await player.setAudioSource(audioSource, preload: false);

          if (seekNecessary) {
            player.seek(seek);
            seekNecessary = false;
          }
          await player.play();
          await player.stop();

          if (filesInJsonData > iteration) {
            lengthOfPreviousAudioFiles =
                lengthOfPreviousAudioFiles + audioFile['durationMilliseconds'];
          }
        }
      }
        repetitionSeek = 0;
      }
      if (running) {
        setState(() {
          running = false;
          isPlaying = false;
          currentAudioFileTitle = '';
          currentAudioFileDuration = Duration.zero;

        });
      }

    }
    _loadJsonData(selectedFile);
  }

  void pauseAudioFiles () {

    currentSeekPosition = Duration(milliseconds: player.position.inMilliseconds + lengthOfPreviousAudioFiles.toInt());

    player.pause();

    setState(() {
      running = false;
      isPlaying = false;
      releasedToPlay = false;
    });
    return;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

// not in use
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.deepPurple,
        title: const Text('Start a Program'),
      ),

      body: ListView(
        children: [

/*          const SizedBox(height: 16.0),
            const Center(
              child: Text(
                'Select a file to play',
                style: TextStyle(fontSize: 20.0),
              ),
            ),*/
          const SizedBox(height: 16.0),
          JsonFileDropdown(
            onFileSelected: (String? selectedFile) {
              _loadJsonData(selectedFile);
            },
          ),

          const SizedBox(height: 16.0),

          Row(
            children: [
              const SizedBox(width: 30),
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/pascalmalz.jpg"),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textAlign: TextAlign.left,
                    'Full Duration: ${_formatDuration(totalDuration)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Current Scrolling Time: ${_formatDuration(currentAudioFileDuration)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 55.0, vertical: 5),
            child: Text(
              textAlign: TextAlign.left,
              'Now playing: $currentAudioFileTitle\nTime remaining: ${currentAudioFileDuration.inSeconds} seconds',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
            ),
          ),
          Center(
            child: Container(
              width: 300, // Set the desired width of the square
              height: 300, // Set the desired height of the square
              color: Colors.grey, // Set any background color you want for the box
              child: Image.asset("assets/fileCardPic.jpg"), // Place the image inside the square box
            ),
          ),

          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth - 80.0;
              const double height = 20.0;

              return StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, snapshot) {
                  return ProgressBar(
                    duration: totalDuration,
                    fileDurations: jsonData.map((audioFiles) => Duration(seconds: audioFiles['duration'])).toList(),
                    currentPosition: player.positionStream,
                    lengthOfPreviousAudioFiles: lengthOfPreviousAudioFiles,
                    width: width,
                    height: height,
                    onBulletDrop: (time) {
                      final timeInMs = time.inMilliseconds;
                      releasedToPlay = true;
                      playAudioFilesConsecutively(seekAbs: timeInMs);
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 0.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,

                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: ElevatedButton(

                    onPressed: (isPlaying ?  pauseAudioFiles : playAudioFilesConsecutively),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.deepPurple.withOpacity(0),
                      foregroundColor: Colors.deepPurple.withOpacity(1),
                      shadowColor: Colors.deepPurple.withOpacity(0),
                    ),
                    child: Icon(isPlaying ? Icons.pause_circle_outline_sharp : Icons.play_circle_outline_sharp, size: 80,),

                  ),
                ),
              ),

            ],
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class JsonFileDropdown extends StatefulWidget {
  final Function(String?) onFileSelected;

  const JsonFileDropdown({Key? key, required this.onFileSelected})
      : super(key: key);

  @override
  JsonFileDropdownState createState() => JsonFileDropdownState();
}

class JsonFileDropdownState extends State<JsonFileDropdown> {
  List<String> _jsonFiles = [];
  String? _selectedJsonFile;

  @override
  void initState() {
    super.initState();
    _loadJsonFiles();
  }

  void _loadJsonFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().whereType<File>().toList();

    setState(() {
      _jsonFiles = files
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.path.split('/').last)
          .toList();
      _selectedJsonFile = _jsonFiles.isNotEmpty ? _jsonFiles.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(

        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.deepPurple,
            width: 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(

            value: _selectedJsonFile,
            items: _jsonFiles.map((String file) {
              return DropdownMenuItem<String>(
                value: file,
                child: Text(
                  file,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (String? selectedFile) {
              setState(() {
                _selectedJsonFile = selectedFile;
              });
              widget.onFileSelected(selectedFile);
            },

            hint: Text(
              'Select JSON file',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
            elevation: 8,
            dropdownColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
