import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:marquee/marquee.dart';
import '../models/composition.dart';

class MixesListWidget extends StatefulWidget {
  @override
  _MixesListWidgetState createState() => _MixesListWidgetState();
}

class _MixesListWidgetState extends State<MixesListWidget> {
  Composition? _currentComposition;

  @override
  Widget build(BuildContext context) {
    final Box<Composition> compositionBox = Hive.box<Composition>('compositionMetadata');

    return ListView.builder(
      itemCount: compositionBox.length,
      itemBuilder: (context, index) {
        final Composition composition = compositionBox.getAt(index)!;
        return _buildCompositionListItem(composition);
      },
    );
  }

  Widget _buildCompositionListItem(Composition composition) {
    return Padding(
      padding: const EdgeInsets.all(10),
      key: ValueKey(composition.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.deepPurple,
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple,
              blurRadius: 3.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: _buildCompositionRow(composition),
          onTap: () {
            // Handle composition selection
            setState(() {
              _currentComposition = composition;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCompositionRow(Composition composition) {
    return Row(
      children: [
        // Placeholder for Play/Pause Button
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Center(
            child: Icon(
              _currentComposition == composition ? Icons.pause_circle_outline : Icons.play_arrow,
              color: Colors.deepPurple,
            ),
          ),
        ),
        const SizedBox(width: 12.0),

        // Composition Title
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurple),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Marquee(
              text: composition.title.length > 15 ? composition.title : ' ' + composition.title,
              style: const TextStyle(fontSize: 16.0),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 20.0,
              velocity: 20.0,
              startPadding: 10.0,
            ),
          ),
        ),
        const SizedBox(width: 8.0),

        // Delete Button
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 0.0001,
              onPressed: () {
                // Implement delete functionality
                _deleteComposition(composition);
              },
              icon: const Icon(Icons.delete),
              color: Colors.deepPurple,
            ),
          ),
        ),
      ],
    );
  }

  void _deleteComposition(Composition composition) async {
    // Implement the delete functionality
    final shouldDelete = await _showDeleteConfirmationDialog();
    if (!shouldDelete) return;

    final Box<Composition> compositionBox = Hive.box<Composition>('compositionMetadata');
    compositionBox.delete(composition.id);

    setState(() {}); // Refresh the list
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to remove this mix?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}
