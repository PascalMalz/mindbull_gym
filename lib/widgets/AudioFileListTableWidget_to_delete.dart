import 'package:flutter/material.dart';

import '../models/audio.dart';


class AudioFileListTableWidget extends StatelessWidget {
  final List<Audio> audioFile;

  const AudioFileListTableWidget({required this.audioFile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: DataTable(
                columnSpacing: 16.0,
                headingRowHeight: 56.0,
                dataRowHeight: 56.0,
                columns: const [
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Repetition')),
                  DataColumn(label: Text('Duration')),
                ],
                rows: audioFile.map((audioFile) {
                  return DataRow(
                    cells: [
                      DataCell(Text(audioFile.title)),
                      DataCell(Text('${audioFile.duration} s')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        // Add your scrollable note and FloatingActionButton here
      ],
    );
  }
}
