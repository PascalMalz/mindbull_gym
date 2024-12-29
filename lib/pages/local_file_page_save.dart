// Filename: local_files_page.dart
//todo speed up load of files
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class LocalFilesPage_save extends StatefulWidget {
  @override
  _LocalFilesPageState createState() => _LocalFilesPageState();
}

class _LocalFilesPageState extends State<LocalFilesPage_save> {
  List<File> localFiles = <File>[];
  List<bool> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadLocalFiles();
    _loadAssetAudioFiles();
  }

  Future<void> _loadLocalFiles() async {
    final dirPath = '${(await getApplicationDocumentsDirectory()).path}/audio';
    final Directory soundDir = Directory(dirPath);

    final files = await soundDir.list().toList();
    print('files from local app storage: $files');
    final audioFiles = files
        .where((entity) =>
    entity is File &&
            _isAudioFileExtension(path.extension(entity.path).toLowerCase()))
        .map((entity) => entity as File)
        .toList();

    setState(() {
      localFiles.addAll(audioFiles);
      selectedFiles.addAll(List<bool>.filled(audioFiles.length, false));
    });
  }


  Future<void> _loadAssetAudioFiles() async {
    List<String> assetPaths = await _loadSoundAssetPaths();
    print('LocalFilesPage _loadAssetAudioFiles start load files!');
    for (final assetPath in assetPaths) {
      print('LocalFilesPage _loadAssetAudioFiles $assetPath');
      final tempFile = await _getTemporaryFileFromAsset(assetPath);
      setState(() {
        localFiles.add(tempFile);
        selectedFiles.add(false);
      });
    }
  }

  Future<List<String>> _loadSoundAssetPaths() async {
    final String manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    print('LocalFilesPage _loadSoundAssetPaths loading manifestMap: $manifestMap');
    return manifestMap.keys
        .where((String key) => key.startsWith('assets/sounds/'))
        .where((String key) => _isAudioFileExtension(path.extension(key)))
        .toList();
  }

  Future<File> _getTemporaryFileFromAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempFile = File('${(await getTemporaryDirectory()).path}/${path.basename(assetPath)}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile;
  }

  bool _isAudioFileExtension(String extension) {
    return extension == '.mp3' ||
        extension == '.wav' ||
        extension == '.aac' ||
        extension == '.m4a' ||
        extension == '.opus' ||
        extension == '.flac' ||
        extension == '.ogg' ||
        extension == '.wma';
  }

  void _confirmSelection() {
    List<File> selected = [];
    for (int i = 0; i < localFiles.length; i++) {
      if (selectedFiles[i]) {
        selected.add(localFiles[i]);
      }
    }
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Local Files'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: localFiles.length,
              itemBuilder: (context, index) {
                final file = localFiles[index];
                return Card(
                  elevation: 5,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(
                      path.basename(file.path),
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Checkbox(
                      value: selectedFiles[index],
                      onChanged: (value) {
                        setState(() {
                          selectedFiles[index] = value!;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        selectedFiles[index] = !selectedFiles[index];
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmSelection,
        child: Icon(Icons.check),
      ),
    );
  }
}
