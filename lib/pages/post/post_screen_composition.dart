import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../api/APIPostPost.dart';
import '../../models/audio.dart';
import '../../models/composition.dart';
import '../../models/composition_audio.dart';
import '../../models/post.dart';
import '../../provider/audio_list_provider.dart';
import '../../provider/single_audio_provider.dart';
import '../../provider/single_image_provider.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:file_picker/file_picker.dart'; // For picking audio files
import 'package:self_code/api/api_post_screen_image_audio.dart';

import '../../provider/user_data_provider.dart';
import '../../widgets/post_card.dart';
import '../local_file_page.dart'; // Import the updated API class
import 'package:path/path.dart' as path;

class CompositionPostPage extends StatefulWidget {
  @override
  _CompositionPostPageState createState() => _CompositionPostPageState();
}

class _CompositionPostPageState extends State<CompositionPostPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Audio? selectedAudioFile;
  Composition? selectedComposition;

  late TextEditingController descriptionController;
  late TextEditingController audioTagController;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
    audioTagController = TextEditingController();

    // Reattach listener
    descriptionController.addListener(_updateDescription);
  }


  void _updateDescription() {
    if (mounted) {
      setState(() {
        print("_updateDescription");
      });
    }
  }
//todo make the descriptionController work again when you come back to the screen

  @override
  void dispose() {
    descriptionController.dispose();
    audioTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<SingleAudioProvider>(context);
    final imageProvider = Provider.of<SingleImageProvider>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Composition'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompositionUploadOptions('Select Image \n (Optional)', Icons.video_library, () => _pickImage(imageProvider)),
                    _buildCompositionUploadOptions('Select Audio', Icons.library_music, () => _pickAudio(audioProvider)),
                  ],
                ),
                TextFormField(
                  controller: audioProvider.descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Tags TextField
                TextFormField(
                  controller: audioProvider.audioTagController,
                  decoration: InputDecoration(labelText: 'Tags'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('Post'),
                  onPressed: _postContent,
                ),
                SizedBox(height: 20),
                //Divider(thickness:1, color: Colors.black,),
                Text('Post Preview:',style: TextStyle(fontSize: 20),),
                // Submit Button

                ValueListenableBuilder(
                  valueListenable: audioProvider.descriptionController,
                  builder: (context, TextEditingValue value, child) {
                    return PostCard(
                      key: ValueKey(value.text),
                      previewAudio: audioProvider.audioFile, // Assuming selectedAudio is the Audio object from the provider
                      previewImage: imageProvider.getImage(),
                      // Directly update widget's post field
                        post: Post(
                          content: value.text,
                          createdAt: DateTime.now(),
                          username: userDataProvider.currentUser?.username,
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _postContent() async {
    if (_formKey.currentState!.validate()) {
      final imageProvider = Provider.of<SingleImageProvider>(context, listen: false);
      final audioProvider = Provider.of<SingleAudioProvider>(context, listen: false);

      final imageFilePath = imageProvider.imagePath;
      final audioFilePath = audioProvider.audioFilePath;
      final description = audioProvider.descriptionController.text;
      final tags = [audioProvider.audioTagController.text]; // Assuming single tag for simplicity
      final durationInMilliseconds = audioProvider.audioDurationInMilliseconds;

      String? result;
      ApiPostPost apiPostPost = ApiPostPost();
      if (selectedAudioFile != null) {
        // Correctly assign to the outer scope result variable
        result = await apiPostPost.uploadPost(
          audioFile: File(selectedAudioFile!.clientAppAudioFilePath),
          imageFile: imageFilePath != null ? File(imageFilePath) : null,
          description: description,
          tags: tags,
          onUploadProgress: (int sent, int total) {
            print("Upload progress: $sent/$total");
          },
        );
      } else if (selectedComposition != null) {
        // Correctly assign to the outer scope result variable
        result = await apiPostPost.uploadPost(
          composition: selectedComposition,
          imageFile: imageFilePath != null ? File(imageFilePath) : null,
          description: description,
          tags: tags,
        );
      } else {
        print("No audio or composition selected for posting");
        return;
      }
      print("Uploading post, result: $result");

      // Now, 'result' will not be null if any of the above conditions were true and returned a value
      if (result != null && result.startsWith("Error")) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      } else if (result == "Post uploaded successfully") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unexpected error occurred: $result")));
      }
    }
  }

  Future<void> _pickImage(SingleImageProvider imageProvider) async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageProvider.setImagePath(pickedFile.path);
    }
  }

  Future<void> _pickAudio(SingleAudioProvider audioProvider) async {
    final audioListModel = Provider.of<AudioListProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add File'),
          content: Text('Choose the source of the file'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                FilePickerResult? pickedFile =
                await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: {'mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg', 'wma'}.toList(),
                );
                if (pickedFile != null && pickedFile.files.single.path != null) {
                  String path = pickedFile.files.single.path!;
                  audioProvider.setAudioFilePath(path);

                  // Initialize the audio player
                  final audioPlayer = AudioPlayer();
                  try {
                    // Load the audio file
                    await audioPlayer.setFilePath(path);

                    // Get the duration
                    final duration = audioPlayer.duration;
                    if (duration != null) {
                      // Set the duration in milliseconds
                      audioProvider.setAudioDurationInMilliseconds(duration.inMilliseconds);
                    }
                  } catch (e) {
                    // Handle the error, e.g., file is not an audio file or file is corrupt
                    print("Error loading audio file: $e");
                  } finally {
                    // Always release the resources used by the audio player
                    audioPlayer.dispose();
                  }
                }
              },
              child: Text('From Phone'),
            ),
            TextButton(
              onPressed: () async {
                dynamic selectedFileOrComposition = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocalFilesPage(filter: DisplayFilter.composition),
                  ),
                );
                if (selectedFileOrComposition is Audio) {
                  setState(() {
                    selectedAudioFile = selectedFileOrComposition; // Store the selected audio file
                    selectedComposition = null; // Reset composition selection
                  });
                  print('selected File is single audio: ${selectedFileOrComposition.id}');
                } else if (selectedFileOrComposition is Composition) {
                  setState(() {
                    selectedComposition = selectedFileOrComposition; // Store the selected composition
                    selectedAudioFile = null; // Reset audio file selection
                  });
                  Composition composition = selectedFileOrComposition;
                  print("selected File is Composition: ${selectedFileOrComposition.id}");
                } else {
                  // Handle error or unexpected type
                  print("Unknown type returned from LocalFilesPage");
                }
                Navigator.of(context).pop();
              },
              child: Text('From App'),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildCompositionUploadOptions(String label, IconData icon, VoidCallback onPressed) {
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