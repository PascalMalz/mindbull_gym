// Filename: thumbnail_selector.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'dart:io'; // Ensure you're using this import for the File class

class ThumbnailSelector extends StatefulWidget {
  final String videoPath;

  ThumbnailSelector({required this.videoPath});

  @override
  _ThumbnailSelectorState createState() => _ThumbnailSelectorState();
}

class _ThumbnailSelectorState extends State<ThumbnailSelector> {
  List<Uint8List?>? _thumbnails;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  _initializeVideo() async {
    _controller = VideoPlayerController.file(File(widget.videoPath)); // Use File from dart:io here
    await _controller.initialize();
    _generateThumbnails(_controller.value.duration);
  }

  // This function extracts frames from the video.
  _generateThumbnails(Duration duration) async {
    final int _thumbnailCount = 10; // Change this as required
    final List<Uint8List?>? thumbs = [];
    final double _eachPart = duration.inSeconds / _thumbnailCount;

    for (int i = 1; i <= _thumbnailCount; i++) {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: widget.videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: (_eachPart * i).toInt() * 1000,
        quality: 75,
      );
      thumbs?.add(uint8list);
    }

    setState(() {
      _thumbnails = thumbs?.cast<Uint8List?>();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Thumbnail')),
      body: _thumbnails == null
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        itemCount: _thumbnails!.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop(_thumbnails![index]);
            },
            child: _thumbnails![index] != null
                ? Image.memory(_thumbnails![index]!)  // Display the image using Image.memory
                : Container(color: Colors.grey), // Placeholder for null or missing thumbnails
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
