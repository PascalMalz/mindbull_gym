import 'package:flutter/material.dart';
import '../widgets/MixesListWidget.dart';

class MixesScreenLibrary extends StatefulWidget {
  const MixesScreenLibrary({super.key});

  @override
  State<MixesScreenLibrary> createState() => _MixesScreenLibraryState();
}

class _MixesScreenLibraryState extends State<MixesScreenLibrary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Mixes'),
        backgroundColor: Colors.transparent,
      ),
      body: MixesListWidget(), // Use the MixesListWidget directly
    );
  }
}

