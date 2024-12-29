import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../models/audio.dart';
import '../models/composition_audio.dart';
import '../provider/audio_list_provider.dart';
import '../models/composition.dart';
import '../widgets/seek_new_try/audio_player_composition_widget.dart';

class AfterJoin extends StatefulWidget {
  @override
  _AfterJoinState createState() => _AfterJoinState();
}

class _AfterJoinState extends State<AfterJoin> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveComposition() async {
    final audioProvider = Provider.of<AudioListProvider>(context, listen: false);
    Composition composition = audioProvider.createComposition();

    // Print the composition details
    print("Saving Composition: ${composition.id}");
    print("Title: ${composition.title}");
    print("Description: ${composition.description}");
    for (CompositionAudio compAudio in composition.compositionAudios) {
      print("CompositionAudio ID: ${compAudio.compositionAudioId}, Position: ${compAudio.audioPosition}, Repetition: ${compAudio.audioRepetition}");
      if (compAudio.content is Audio) {
        Audio audioFile = compAudio.content;
        print("  AudioFile Title: ${audioFile.title}, File Path: ${audioFile.clientAppAudioFilePath}, Duration: ${audioFile.duration}");
        // Add more details as needed
      } else if (compAudio.content is Composition) {
        // For nested compositions, you might print basic details or recursively print more
        print("  Nested Composition ID: ${compAudio.content.id}");
      }
    }

    // Continue with saving the composition
    var box = await Hive.openBox<Composition>('compositionMetadata');
    await box.add(composition);
    audioProvider.clearAll();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Composition saved successfully')));
  }

  void _printCompositionDetails() {
    final audioProvider = Provider.of<AudioListProvider>(context, listen: false);
    Composition composition = audioProvider.createComposition();

    printComposition(composition);  // Call the recursive print function
  }

// Recursive function to print composition details
  void printComposition(Composition composition, {int depth = 0}) {
    // Define the maximum depth for printing
    const int maxDepth = 10;

    // Check if the maximum depth has been reached
    if (depth > maxDepth) {
      print("Maximum depth reached, stopping further output...");
      return;  // Stop recursion if depth exceeds maxDepth
    }

    String indent = ' ' * depth * 2;  // Indentation for readability

    // Print the composition details
    print("${indent}Composition ID: ${composition.id}");
    print("${indent}Title: ${composition.title}");
    print("${indent}Description: ${composition.description}");
    for (CompositionAudio compAudio in composition.compositionAudios) {
      print("${indent}CompositionAudio ID: ${compAudio.compositionAudioId}, Position: ${compAudio.audioPosition}, Repetition: ${compAudio.audioRepetition}");
      if (compAudio.content is Audio) {
        Audio audioFile = compAudio.content;
        print("${indent}  AudioFile Title: ${audioFile.title}, File Path: ${audioFile.clientAppAudioFilePath}, Duration: ${audioFile.duration}");
      } else if (compAudio.content is Composition) {
        print("${indent}  compAudio.content.id: ${compAudio.content.id}");
        printComposition(compAudio.content, depth: depth + 1);  // Recursively print nested composition
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioListProvider>(context);
/*
    // Filter out only those compAudio.contents that are AudioFile instances
    final audioFiles = audioProvider.compositionAudios
        .where((compAudio) => compAudio.content is AudioFile)
        .map((compAudio) => compAudio.content as AudioFile)
        .toList();
*/

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Media Editor')),
      body: Column(
        children: [
          // Use AudioPlayerWidget and pass the audio files
          // Ensure audioFiles is a List<AudioFile> now
          AudioPlayerCompositionWidget(composition: audioProvider.createComposition(), autoplayEnabled: false,),
          ElevatedButton(
            onPressed: _printCompositionDetails,  // Calls the print function
            child: Text("Print Composition Details"),
          ),
          ElevatedButton(
            onPressed: _saveComposition,
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
