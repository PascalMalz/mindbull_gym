// Filename: thumbnail_selector.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'dart:io'; // Ensure you're using this import for the File class

class ThumbnailSelector extends StatefulWidget {
  final String videoPath;

  ThumbnailSelector({required this.videoPath});

  @override
  _ThumbnailSelectorWidgetState createState() => _ThumbnailSelectorWidgetState();
}

class _ThumbnailSelectorWidgetState extends State<ThumbnailSelector> {
  List<Image?>? _thumbnails;
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
    final List<Image?> thumbs = [];
    final double _eachPart = duration.inSeconds / _thumbnailCount;

    for (int i = 1; i <= _thumbnailCount; i++) {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: widget.videoPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: (_eachPart * i).toInt() * 1000,
        quality: 75,
      );
      thumbs.add(uint8list != null ? Image.memory(uint8list) : null);
    }

    setState(() {
      _thumbnails = thumbs;
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
            child: _thumbnails![index],
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

class VideoAndThumbnailPicker extends StatefulWidget {
  @override
  _VideoAndThumbnailPickerState createState() => _VideoAndThumbnailPickerState();
}

class _VideoAndThumbnailPickerState extends State<VideoAndThumbnailPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pick Video & Thumbnail")),
      body: Center(
        child: ElevatedButton(
          onPressed: _selectVideoAndThumbnail,
          child: Text("Select Video"),
        ),
      ),
    );
  }

  Future<void> _selectVideoAndThumbnail() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      File file = File(result.files.single.path!);
      String videoPath = file.path;

      final selectedThumbnail = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ThumbnailSelector(videoPath: videoPath)),
      );

      // Use selectedThumbnail as needed...
      if (selectedThumbnail != null) {
        // Here, you can save or process the chosen thumbnail.
      }
    } else {
      // User canceled the picker or an error occurred
    }
  }
}
