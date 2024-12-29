
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
//import of models
import 'package:self_code/models/audio.dart';
//APIs
import '../api/api_audio.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;

  CategoryScreen({required this.categoryName});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiAudio _musicApi = ApiAudio();
  List<Audio> _audioFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchAudioFilesForCategory();
  }

  Future<void> _fetchAudioFilesForCategory() async {
    final audioFiles = await _musicApi.fetchAudioFilesForCategory(widget.categoryName);
    setState(() {
      _audioFiles = audioFiles;
    });
  }



  double _downloadProgress = 0.0; // Initialize with 0 progress

  Future<void> _downloadAudioFile(String filePath, String title) async {
    const String baseUrl = 'http://82.165.125.163';
    final downloadUrl = '$baseUrl/download/$filePath';
    print(downloadUrl);
    try {
      final path = await FileDownloader.downloadFile(
        url: downloadUrl,
        name: title, // Use the title as the file name
        onProgress: (String? fileName, double progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
        onDownloadCompleted: (String path) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File downloaded to $path'),
              backgroundColor: Colors.green, // Set the background color to green
            ),
          );
        },
        onDownloadError: (String error) {
          print('downloadFile error: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to download file: $error'),
              backgroundColor: Colors.red, // Set the background color to red
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initiate download: $e'),
          backgroundColor: Colors.red, // Set the background color to red
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Center(
        child: _audioFiles.isEmpty
            ? Text('No audio files available')
            : ListView.builder(
          itemCount: _audioFiles.length,
          itemBuilder: (context, index) {
            final audioFile = _audioFiles[index];
            return ListTile(
              leading: const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/pascalmalz.jpg"),
              ),
              title: Text('${audioFile.title},${audioFile.username}',style: TextStyle(fontSize: 10),),
              subtitle: Text('${audioFile.id},${audioFile.userTimeStamp}',style: TextStyle(fontSize: 10), ),
              trailing: ElevatedButton(
                onPressed: () {
                  _downloadAudioFile(audioFile.id, audioFile.title);
                },
                child: Text('Download'),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _downloadProgress > 0
          ? LinearProgressIndicator(
        value: _downloadProgress / 100, // Divide by 100 to get a value between 0 and 1
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      )
          : null, // Only show progress bar if there's a download in progress
    );
  }
}




