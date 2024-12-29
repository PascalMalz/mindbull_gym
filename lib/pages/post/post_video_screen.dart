import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../api/api_post_video.dart';
import '../../provider/single_video_provider.dart';
import '../../widgets/video_player_widget.dart';
//todo pause already selected running video when click on select / record

class PostVideoScreen extends StatefulWidget {
  @override
  _PostVideoScreenState createState() => _PostVideoScreenState();
}

class _PostVideoScreenState extends State<PostVideoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _videoFile;  // This holds the current video file
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  Future<void> _pickVideo() async {
    final videoProvider = Provider.of<SingleVideoProvider>(context, listen: false);
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path); // Set the new video file
        videoProvider.videoFile = _videoFile; // Update the provider with the new video file
      });
    }
  }


  Future<void> _recordVideo() async {
    final videoProvider = Provider.of<SingleVideoProvider>(context, listen: false);
    final pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        videoProvider.videoFile = File(pickedFile.path); // Set the video file in the provider
      });
    }
  }


  void _postVideo() async {
    final videoProvider = Provider.of<SingleVideoProvider>(context, listen: false);

    final videoFilePath = videoProvider.videoFile?.path;
    final description = videoProvider.descriptionController.text;
    final tags = [videoProvider.tagsController.text]; // Assuming single tag for simplicity

    if (videoFilePath != null) {
      File videoFile = File(videoFilePath);

      // Use your API method to upload the video
      // For instance: ApiPostScreenVideo().uploadVideo(videoFile, description, tags);
      // Handle the API response accordingly

      // Example response handling
      String? result = await ApiPostScreenVideo().uploadVideo(videoFile, description, tags);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Video uploaded successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $result")));
      }

      videoProvider.clear(); // Clear the provider data after posting
    }
  }

  @override
  void dispose() {
    // Always dispose controllers when the widget is removed from the widget tree
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<SingleVideoProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Video'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVideoOption('Upload Video \n from Gallery', Icons.video_library, _pickVideo),
                _buildVideoOption('Record a Video', Icons.videocam, _recordVideo),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: videoProvider.descriptionController, // Use provider's controller
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: videoProvider.tagsController, // Use provider's controller
              decoration: InputDecoration(labelText: 'Tags'),
            ),
            SizedBox(height: 16),
            if (_videoFile != null)
              Container(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: VideoPlayerWidget(videoFile: _videoFile!), // A widget that plays the selected/recorded video
                ),
                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _postVideo,
              child: Text('Post Video'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildVideoOption(String label, IconData icon, VoidCallback onPressed) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        onTap: onPressed,
        child: CircleAvatar(
          radius: 30, // Adjust the size of the circle here
          backgroundColor: Colors.deepPurple,
          child: Icon(icon, size: 30, color: Colors.white), // Adjust icon size here
        ),
      ),
      SizedBox(height: 8),
      Text(
        label,
        textAlign: TextAlign.center,  // Center align text
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
    ],
  );
}
