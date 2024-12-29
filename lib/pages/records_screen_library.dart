import 'package:flutter/material.dart';

import '../widgets/records_screen_widget.dart';

class RecordsScreenLibrary extends StatefulWidget {
  const RecordsScreenLibrary({super.key});

  @override
  State<RecordsScreenLibrary> createState() => _RecordsScreenLibraryState();
}

class _RecordsScreenLibraryState extends State<RecordsScreenLibrary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade900,
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Records'),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(child: RecordsListWidget()),
    );
  }
}
