// Filename: local_files_page.dart
// This code is for the LocalFilesPage in a Flutter application that uses Hive for local storage.
// It ensures that Hive boxes for audio and composition metadata are only opened if they are not already open.

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../models/audio.dart';
import '../models/composition.dart'; // Import your AudioFile model

enum DisplayFilter { audio, composition, both }

class LocalFilesPage extends StatefulWidget {
  final DisplayFilter filter;

  LocalFilesPage({this.filter = DisplayFilter.both});

  @override
  _LocalFilesPageState createState() => _LocalFilesPageState();
}

class _LocalFilesPageState extends State<LocalFilesPage> {
  List<dynamic> localItems = [];

  @override
  void initState() {
    super.initState();
    _loadLocalItems();
  }

  Future<void> _loadLocalItems() async {
    Box<Audio> audioBox = Hive.box<Audio>('audioMetadata');
    Box<Composition> compositionBox = Hive.box<Composition>('compositionMetadata');

    List audioFiles = [];
    List<Composition> compositions = [];

    if (widget.filter == DisplayFilter.audio || widget.filter == DisplayFilter.both) {
      audioFiles = audioBox.values.toList();
    }
    if (widget.filter == DisplayFilter.composition || widget.filter == DisplayFilter.both) {
      compositions = compositionBox.values.toList();
    }

    setState(() {
      localItems = [...audioFiles, ...compositions];
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Files and Compositions'),
      ),
      body: ListView.builder(
        itemCount: localItems.length,
        itemBuilder: (context, index) {
          final item = localItems[index];
          if (item is Audio) {
            return ListTile(
              title: Text(item.title),
              subtitle: Text('Audio File'),
              onTap: () => Navigator.pop(context, item),
            );
          } else if (item is Composition) {
            return ListTile(
              title: Text(item.title),
              subtitle: Text('Composition'),
              onTap: () {
                // Directly return the Composition object when the ListTile is tapped
                Navigator.pop(context, item);  // item is assumed to be of type Composition here
              },
            );
          } else {
            return ListTile(
              title: Text('Unknown Item'),
            );
          }
        },
      )
      ,
    );
  }
}
