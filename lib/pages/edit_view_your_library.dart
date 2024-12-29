//Todo remove deleted files form storrage and from all json files where it was used

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:convert';
//import of models
import 'package:self_code/models/audio.dart';
import 'package:self_code/widgets/common_bottom_navigation_bar.dart';
import 'package:uuid/uuid.dart';

enum FileType { mp3, json, all }



List<Audio> _audioFileList = [];



class YourLibrary extends StatefulWidget {
  const YourLibrary({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _YourLibraryState createState() => _YourLibraryState();
}

class _YourLibraryState extends State<YourLibrary> {
  PlayerController _wavePlayer = PlayerController();
  String? _currentclientAppAudioFilePath;
  Widget? _waveformWidget;
  FileType _selectedFileType = FileType.all;

  @override
  void initState() {
    super.initState();
    _showFilesInDirectory();
  }

  @override
  void dispose() {
    _wavePlayer.dispose();
    super.dispose();
  }

  void _showFilesInDirectory() {
    _audioFileList.clear(); // Clear the list before populating it

    getApplicationDocumentsDirectory().then((directory) {
      directory.list(recursive: false).listen((entity) {
        if (entity is File) {
          final extension = path.extension(entity.path).toLowerCase();
          if (_selectedFileType == FileType.all ||
              (_selectedFileType == FileType.mp3 && _isMp3File(extension)) ||
              (_selectedFileType == FileType.json && _isJsonFile(extension))) {
            final audioFile = Audio(
              id: Uuid().v4(),
              title: path.basenameWithoutExtension(entity.path),
              clientAppAudioFilePath: entity.path,
            );
            setState(() {
              _audioFileList.add(audioFile);
            });
          }
        }
      });
    });
  }

  bool _isMp3File(String extension) {
    final validExtensions = ['.mp3', '.wav', '.aac', '.m4a', '.flac', '.ogg', '.wma'];
    return validExtensions.contains(extension.toLowerCase());
  }

  bool _isJsonFile(String extension) {
    return extension.toLowerCase() == '.json';
  }

  Future<void> _playFile(String clientAppAudioFilePath) async {
    _wavePlayer.stopAllPlayers();
    _wavePlayer = PlayerController();

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
          fixedWaveColor: Colors.black26,
          liveWaveColor: Colors.deepPurple,
          spacing: 6,
        ),
      );
    });

    await _wavePlayer.startPlayer(finishMode: FinishMode.stop);
  }

  void _deleteFile(Audio audioFile) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: const Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAudioFile(audioFile);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAudioFile(Audio audioFile) async {
    final file = File(audioFile.clientAppAudioFilePath);

    if (await file.exists()) {
      await file.delete();
    }

    _removeAudioFileFromFileList(audioFile.clientAppAudioFilePath);
    _removeFileFromAllJsonFiles(audioFile.clientAppAudioFilePath);

    setState(() {});
  }


  void _removeFileFromAllJsonFiles(String filePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final jsonFiles = await appDir.list(recursive: true).where((entity) => entity.path.endsWith('.json')).toList();

    for (final jsonFile in jsonFiles) {
      final jsonString = await File(jsonFile.path).readAsString();
      final jsonData = json.decode(jsonString) as List<dynamic>;

      final updatedData = jsonData.where((item) {
        final itemclientAppAudioFilePath = item['clientAppAudioFilePath'] as String?;
        return itemclientAppAudioFilePath != filePath;
      }).toList();

      final updatedJsonString = json.encode(updatedData);

      if (updatedData.isNotEmpty) {
        await File(jsonFile.path).writeAsString(updatedJsonString);
      } else {
        await File(jsonFile.path).delete();
      }
    }
  }

  Audio? _removeAudioFileFromFileList(String filePath) {
    final audioFile = _audioFileList.firstWhere((audioFile) => audioFile.clientAppAudioFilePath == filePath);
    if (audioFile != null) {
      _audioFileList.remove(audioFile);
    }
    return audioFile;
  }







  void _filterByFileType(FileType fileType) {
    setState(() {
      _selectedFileType = fileType;
      _audioFileList.clear();
    });
    _showFilesInDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterButton(
                text: 'MP3',
                isActive: _selectedFileType == FileType.mp3 ||
                    _selectedFileType == FileType.all,
                onPressed: () => _filterByFileType(
                  _selectedFileType == FileType.mp3 || _selectedFileType == FileType.all
                      ? FileType.all
                      : FileType.mp3,
                ),
              ),
              const SizedBox(width: 8.0),
              FilterButton(
                text: 'JSON',
                isActive: _selectedFileType == FileType.json ||
                    _selectedFileType == FileType.all,
                onPressed: () => _filterByFileType(
                  _selectedFileType == FileType.json || _selectedFileType == FileType.all
                      ? FileType.all
                      : FileType.json,
                ),
              ),
              const SizedBox(width: 8.0),
              FilterButton(
                text: 'All',
                isActive: _selectedFileType == FileType.all,
                onPressed: () => _filterByFileType(FileType.all),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _audioFileList.length,
              itemBuilder: (context, index) {
                final audioFile = _audioFileList[index];
                return ListTile(
                  title: Row(
                    children: [
                      IconButton(
                        icon: _currentclientAppAudioFilePath == audioFile.clientAppAudioFilePath
                            ? const Icon(Icons.pause_circle_outline)
                            : const Icon(Icons.play_arrow),
                        onPressed: () {
                          setState(() {
                            if (_currentclientAppAudioFilePath == audioFile.clientAppAudioFilePath) {
                              _wavePlayer.pausePlayer();
                            } else {
                              _playFile(audioFile.clientAppAudioFilePath);
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        audioFile.title,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteFile(audioFile),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      if (_currentclientAppAudioFilePath == audioFile.clientAppAudioFilePath) {
                        _wavePlayer.pausePlayer();
                      } else {
                        _playFile(audioFile.clientAppAudioFilePath);
                      }
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          if (_waveformWidget != null) _waveformWidget!,
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const FilterButton({
    Key? key,
    required this.text,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        backgroundColor: isActive
            ? Theme.of(context).primaryColor
            : Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
