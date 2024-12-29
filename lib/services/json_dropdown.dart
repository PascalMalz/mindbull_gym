import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JsonFileDropdown extends StatefulWidget {
  const JsonFileDropdown({Key? key}) : super(key: key);

  @override
  _JsonFileDropdownState createState() => _JsonFileDropdownState();
}

class _JsonFileDropdownState extends State<JsonFileDropdown> {
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedJsonFile,
          items: _jsonFiles.map((String file) {
            return DropdownMenuItem<String>(
              value: file,
              child: Text(
                file,
                style: TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (String? selectedFile) {
            setState(() {
              _selectedJsonFile = selectedFile;
            });
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
    );
  }
}
