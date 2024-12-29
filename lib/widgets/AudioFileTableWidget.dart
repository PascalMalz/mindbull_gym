  import 'package:flutter/material.dart';
import '../models/audio.dart';

class AudioFileTableWidget extends StatelessWidget {
  final List<Audio> audioFileList;
  final bool isPlaying;
  final Function(Audio) onDelete;

  const AudioFileTableWidget({
    required this.audioFileList,
    required this.isPlaying,
    required this.onDelete,
  });

  void _showDeleteConfirmation(BuildContext context, Audio audioFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this audio file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Call a callback to handle the deletion in the parent widget
                onDelete(audioFile);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    print('Received audioFileList: $audioFileList');
    return ReorderableListView(
      buildDefaultDragHandles: false,
      onReorder: (int oldIndex, int newIndex) {
        // Implement reorder logic if needed
      },
      children: <Widget>[
        for (final audioFile in audioFileList.reversed)

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            key: ValueKey(audioFile),
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
              child: ReorderableDragStartListener(
                key: ValueKey(audioFile),
                index: audioFileList.indexOf(audioFile),
                child: Container(

                  child:  Column(children:[
                    SizedBox(height: 10,),
                    Text(audioFile.title ,style: TextStyle(fontSize: 16, color: Colors.white), ),
                    Text(audioFile.userTimeStamp,style: TextStyle(fontSize: 16, color: Colors.white),),
                    Text(audioFile.username,style: TextStyle(fontSize: 16, color: Colors.white),),
                    Text(audioFile.id,style: TextStyle(fontSize: 16, color: Colors.white),),
                    for (final tag in audioFile.tags)
                      Text(tag,style: TextStyle(fontSize: 16, color: Colors.white),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            _showDeleteConfirmation(context, audioFile);
                          },
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
