import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import '../api/api_audio.dart';

//todo check first if logged in and if address is correct and change ip to domain

class MusicUploadScreen extends StatefulWidget {
  @override
  _MusicUploadScreenState createState() => _MusicUploadScreenState();
}
//todo some files get broken after upload no thumbnail and not playable from android. Even if file is downloaded directly from server with ftp it is received there already broken. Wrote an bug report in dio library on github

class _MusicUploadScreenState extends State<MusicUploadScreen> {
  File? _musicFile;
  List<String> _tags = [];
  double _uploadProgress = 0.0;
  String _customFileName = '';
  TextEditingController _tagsController = TextEditingController();


  Future<void> _uploadMusic(File musicFile) async {
    ApiAudio musicApi = ApiAudio();

    setState(() {
      _isUploading = true;
      _showSuccessMessage = false;
      _showErrorMessage = false;
    });

    await musicApi.uploadMusic(
      musicFile: musicFile,
      userName: 'PascalMalz',
      customFileName: _customFileName,
      tags: _tagsController.text.split(','),
      onProgress: (double progress) {
        setState(() {
          _uploadProgress = progress;
        });
      },
      onSuccess: () {
        setState(() {
          _isUploading = false;
          _showSuccessMessage = true;
        });
      },
      onError: (String errorMessage) {
        setState(() {
          _isUploading = false;
          _showErrorMessage = true;
        });
        print(errorMessage); // You can display this error message to the user if needed
      },
    );
  }


  Future<File?> _pickMusic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio, // Only allow audio files
    );
    if (result == null || result.files.isEmpty) return null;
    return File(result.files.single.path!);
  }
  // Function to request necessary permission
  Future<void> _requestPermission() async {
    // Check if the permission is already granted
    if (await Permission.storage.isGranted) {
      // Permission already granted, proceed with file selection and upload
      return;
    }

    // Request the permission
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with file selection and upload
      return;
    }

    // Handle the case when permission is denied or permanently denied
    if (status.isDenied || status.isPermanentlyDenied) {
      // Show an error message or guide the user to app settings to enable the permission
      print('Storage permission denied. Please enable the permission in app settings.');
    }
  }

  bool _isUploading = false;
  bool _showSuccessMessage = false;
  bool _showErrorMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Music')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Custom File Name (Optional)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) {
                      _customFileName = value;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Request necessary permission
                      await _requestPermission();

                      // Continue with the file selection and upload logic
                      File? musicFile = await _pickMusic();
                      if (musicFile != null) {
                        setState(() {
                          _musicFile = musicFile;
                          _showSuccessMessage = false;
                          _showErrorMessage = false;
                        });
                      }
                    },
                    child: Text('Select Music File'),
                  ),
                  if (_musicFile != null)
                    Text('Selected Music File: ${path.basename(_musicFile!.path)}'),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: 'Enter Tags (comma-separated)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_musicFile != null)
                    Column(
                      children: [
                        if (!_isUploading && !_showSuccessMessage && !_showErrorMessage)
                          ElevatedButton(
                            onPressed: () async {
                              // Update the _tags list using the entered text
                              _tags = _tagsController.text.split(',');

                              setState(() {
                                _isUploading = true;
                                _showSuccessMessage = false;
                                _showErrorMessage = false;
                              });
                              try {
                                await _uploadMusic(_musicFile!);
                              } catch (e) {
                                setState(() {
                                  _isUploading = false;
                                  _showErrorMessage = true;
                                });
                              }
                            },
                            child: Text('Upload Sound'),
                          ),
                        if (_isUploading)
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: CircularProgressIndicator(
                                  value: _uploadProgress/100,
                                ),
                              ),
                              Text('${(_uploadProgress).toStringAsFixed(2)}%'),
                            ],
                          ),
                        if (_showSuccessMessage)
                          Container(
                            padding: EdgeInsets.all(10),
                            color: Colors.green,
                            child: Text(
                              'Sound file uploaded!',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_showErrorMessage)
                          Container(
                            padding: EdgeInsets.all(10),
                            color: Colors.red,
                            child: Text(
                              'Failed to upload the file',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

