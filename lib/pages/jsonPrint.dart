import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:self_code/Services/json_dropdown.dart';
import 'package:self_code/widgets/common_sound_progress_bar.dart';
import 'package:self_code/widgets/play_icon_button.dart';

class ViewJson extends StatefulWidget {
  const ViewJson({Key? key}) : super(key: key);

  @override
  _ViewJsonState createState() => _ViewJsonState();
}

class _ViewJsonState extends State<ViewJson> {
  Duration programDuration = Duration(hours: 1, minutes: 5, seconds: 10);
  List<File> jsonFiles = [];
  String? selectedFileName;
  String? selectedJsonData;

  @override
  void initState() {
    super.initState();
    _getJsonFiles();
  }

  Future<void> _getJsonFiles() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      List<FileSystemEntity> files = appDir.listSync();

      List<File> jsonFilesList = [];
      for (FileSystemEntity file in files) {
        if (file.path.endsWith('.json')) {
          jsonFilesList.add(File(file.path));
        }
      }

      setState(() {
        jsonFiles = jsonFilesList;
      });
    } catch (error) {
      // Handle error
    }
  }

  Future<void> _loadJsonData() async {
    try {
      if (selectedFileName != null) {
        File selectedFile = jsonFiles.firstWhere(
              (file) => file.path.endsWith(selectedFileName!),
          orElse: () => File(''),
        );
        String jsonString = await selectedFile.readAsString();

        setState(() {
          selectedJsonData = jsonString;
          print(jsonString);
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspect JSON Files'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 16.0),
          Center(
            child: Text(
              'Please select a file to view',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          SizedBox(height: 16.0),
          DropdownButton<String>(
            value: selectedFileName,
            onChanged: (String? newValue) {
              setState(() {
                selectedFileName = newValue;
                selectedJsonData = null;
              });
              _loadJsonData();
            },
            items: jsonFiles.map((File file) {
              String fileName = file.path.split('/').last;
              return DropdownMenuItem<String>(
                value: fileName,
                child: Text(fileName),
              );
            }).toList(),
          ),
          SizedBox(height: 16.0),
          if (selectedJsonData != null)
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Text(selectedJsonData!),
            ),
        ],
      ),
    );
  }
}
