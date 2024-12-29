import '../models/audio.dart';
import '../models/composition.dart';
import 'package:flutter/material.dart';

import '../models/composition_audio.dart';

//need to loop through column to replace all the single cards from one same composition with a big card of that composition

class CompositionTreeView extends StatelessWidget {
  final Composition composition;
  final Set<String> drawnCompositions;

  CompositionTreeView({
    required this.composition,
    Set<String>? drawnCompositions,
  }) : this.drawnCompositions = drawnCompositions ?? {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: composition.compositionAudios.map((compAudio) {
        return _buildCompositionAudioRow(context, compAudio, composition);
      }).toList(), // This reverses the order of the children
    );
  }

  Widget _buildCompositionAudioRow(BuildContext context, CompositionAudio compAudio, Composition parentComposition) {
    // Original list of widgets in the order they were added
    List<Widget> rowChildren = [
      _buildCompositionCard(parentComposition.title, context),
      // Other widgets that should be in the row
    ];

    // Adding the composition audio column widgets
    rowChildren.addAll(_buildCompositionAudioColumn(context, compAudio));

    // Reverse the order of row children
    List<Widget> reversedRowChildren = rowChildren.reversed.toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: reversedRowChildren,
    );
  }



  List<Widget> _buildCompositionAudioColumn(BuildContext context, CompositionAudio compAudio) {
    List<Widget> widgets = [];
    print('compAudio: $compAudio');
    if (compAudio.content is Audio) {
      // Single Audio
      Audio audio = compAudio.content as Audio;
      widgets.add(_buildAudioCard(audio, compAudio.audioRepetition, context));
    } else if (compAudio.content is Composition) {
      // Nested Composition
      Composition? nestedComposition = compAudio.content as Composition?;
      print('nestedComposition: $nestedComposition');
      if (nestedComposition != null) {
        widgets.add(CompositionTreeView(composition: nestedComposition));
      }
    }
    print('_buildCompositionAudioColumn widget $widgets');
    return widgets;
  }


  Widget _buildCompositionCard(String title, BuildContext context) {
    return SizedBox(
      width: 100,
      height:100,
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            // Handle tap event here
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(title),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioCard(Audio audio, int repetition, BuildContext context) {
    return SizedBox(
      width: 100,
      height:100,
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            // Handle tap event here
          },
          child: ListTile(
            title: Text(audio.title),
            subtitle: Text('Repetitions: $repetition'),
          ),
        ),
      ),
    );
  }
}


