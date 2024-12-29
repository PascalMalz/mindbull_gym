import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../models/audio.dart'; // Your AudioFile model
import '../models/composition.dart'; // Your Composition model

class ViewDataPage extends StatefulWidget {
  @override
  _ViewDataPageState createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<ViewDataPage> {
  List<Audio> audioFiles = [];
  List<Composition> compositions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var audioBox = await Hive.openBox<Audio>('audioMetadata');
    audioFiles = audioBox.values.toList();

    var compositionBox = await Hive.openBox<Composition>('compositionMetadata');
    compositions = compositionBox.values.toList();

    setState(() {}); // Refresh UI with the loaded data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Hive Data"),
      ),
      body: ListView(
        children: [
          ...audioFiles.map((audio) => ListTile(
            title: Text(audio.title),
            subtitle: Text("Duration: ${audio.duration}"),
          )),
          ...compositions.map((comp) => ListTile(
            title: Text(comp.title),
            subtitle: Text("Created At: ${comp.createdAt}"),
          )),
        ],
      ),
    );
  }
}
