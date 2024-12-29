// Filename: media_editor_page.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../provider/media_list_provider.dart';
import '../services/thumbnail_selector.dart';


import 'dart:typed_data';

class MediaEditorPage extends StatefulWidget {
  @override
  _MediaEditorPageState createState() => _MediaEditorPageState();
}

class _MediaEditorPageState extends State<MediaEditorPage> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  final TransformationController _transformationController = TransformationController();
  late Matrix4 _startingMatrix;


  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset('');
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: false,
      looping: false,
    );
  }

  // Function to choose a thumbnail using the ThumbnailSelector widget
  Future<Uint8List?> _chooseThumbnail(BuildContext context, String videoPath) async {
    final selectedThumbnail = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThumbnailSelector(videoPath: videoPath),
      ),
    );

    print('selectedFunkThumbnail:$selectedThumbnail');

    if (selectedThumbnail != null && selectedThumbnail is Uint8List) {
        return selectedThumbnail;
      // Handle other image provider types similarly.
      // e.g., NetworkImage, MemoryImage, etc.
    }



    return null;
  }


  //Create and addMedia to provider class
  void _addMedia() async {
    // Introduce a delay here before opening the file picker/gallery
    //await Future.delayed(Duration(seconds: 2));

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mp3', 'jpg', 'png'],
    );

    print('File picked: $result');

    if (result != null) {
      final path = result.files.single.path!;
      final mediaType = _determineMediaType(path);

      // Create a MediaItem object
      MediaItem mediaItem = MediaItem(path: path, type: mediaType);

      // Add mediaItem to the provider
      Provider.of<MediaListProvider>(context, listen: false).addMediaItem(mediaItem);

      if (mediaType == MediaType.video) {
        Uint8List? selectedThumbnail = await _chooseThumbnail(context, mediaItem.path);
        print('Fuck selectedThumbnail: $selectedThumbnail');
        if (selectedThumbnail != null) {
          print('selected thumbnail not null');
          int newIndex = Provider.of<MediaListProvider>(context, listen: false).mediaItems.length - 1;
          Provider.of<MediaListProvider>(context, listen: false).updateMediaItemThumbnail(newIndex, selectedThumbnail);

        }
      }
    }
  }


  MediaType _determineMediaType(String path) {
    if (path.endsWith('.mp4')) return MediaType.video;
    if (path.endsWith('.mp3')) return MediaType.audio;
    if (path.endsWith('.jpg') || path.endsWith('.png')) return MediaType.image;

    // Default type
    return MediaType.unknown;
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  void _editOrRemoveTrack(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit or Remove Track'),
          content: Text('Would you like to edit or remove this track?'),
          actions: <Widget>[
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                // Handle editing logic here
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Remove'),
              onPressed: () {
                // Remove track from the provider's list
                Provider.of<MediaListProvider>(context, listen: false).removeMediaItem(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Composition"),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: () {
            // Implement save action
          }),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {
            // Implement more actions
          }),
        ],
      ),
      body: Column(
        children: [
          // Preview section
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              // Update this section to use InteractiveViewer for the video preview
              child: InteractiveViewer(
                transformationController: _transformationController,
                onInteractionStart: (details) {
                  _startingMatrix = _transformationController.value.clone();
                },
                onInteractionEnd: (details) {
                  // Check for zoom constraints or any other post-interaction actions here
                },
                child: Chewie(
                  controller: _chewieController,
                ),
              ),
            ),
          ),
          // Timeline
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(5),
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: Provider.of<MediaListProvider>(context).mediaItems.length,
              itemBuilder: (context, index) {
                MediaItem mediaItem = Provider.of<MediaListProvider>(context).mediaItems[index];
                // Wrap mediaItem.thumbnail in a Future if it's not already one
                Future<Uint8List?>? thumbnailFuture;
                if (mediaItem.thumbnail is Future<Uint8List?>?) {
                  thumbnailFuture = mediaItem.thumbnail as Future<Uint8List?>?;
                  print(mediaItem.thumbnail);
                  print('treuuuuuuu');
                } else {
                  thumbnailFuture = Future.value(mediaItem.thumbnail as Uint8List?);
                }
                if (mediaItem.type == MediaType.video) {
                  return Padding(
                    key: ValueKey(mediaItem),
                    padding: const EdgeInsets.only(bottom: 5.0), // Add some bottom padding for more distance between items
                    child: FutureBuilder<Uint8List?>(
                      future: thumbnailFuture  ?? Future.value(_generateThumbnail(mediaItem.path)),
                      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Add padding inside ListTile for a bigger look
                            leading: GestureDetector(
                              onTap: () async {
                                Uint8List? selectedThumbnail = await _chooseThumbnail(context, mediaItem.path);
                                if (selectedThumbnail != null) {
                                  mediaItem.thumbnail = selectedThumbnail;
                                  Provider.of<MediaListProvider>(context, listen: false).updateMediaItemThumbnail(index, selectedThumbnail);
                                }
                              },
                              //Image.memory --> creates image from image bytes...
                              child: Image.memory(snapshot.data!),
                            ),
                            title: Text("Video Item $index"),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editOrRemoveTrack(index);
                              },
                            ),
                          );
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text("Loading thumbnail..."),
                          );

                        } else {
                          return ListTile(
                            leading: Icon(Icons.error),
                            title: Text("Error loading thumbnail"),
                          );

                        }
                      },
                    ),
                  );
                } else {
                  return Padding(
                    key: ValueKey(mediaItem),
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Add padding inside ListTile for a bigger look
                      leading: GestureDetector(
                        onTap: () async {
                          Uint8List? selectedThumbnail = await _chooseThumbnail(context, mediaItem.path);
                          if (selectedThumbnail != null) {
                            mediaItem.thumbnail = selectedThumbnail;
                            Provider.of<MediaListProvider>(context, listen: false).updateMediaItemThumbnail(index, selectedThumbnail);
                          }
                        },
                        child: Container(
                          width: 60.0, // Increase size of the thumbnail
                          height: 100.0,
                          child: mediaItem.thumbnail != null
                              ? Image.memory(mediaItem.thumbnail!)
                              : Icon(Icons.image, size: 60.0),  // Increase the size of the default image icon
                        ),
                      ),
                      title: Text("Video Item $index"),
                      trailing: IconButton(  // <-- Add this part
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editOrRemoveTrack(index);  // You'll define this function in a moment
                        },
                      ),
                    ),
                  );
                }

              },
            ),



          ),
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Add New Media Track", style: TextStyle(fontSize: 20),),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 30, color: Colors.deepPurple,),
                  onPressed: _addMedia,
                )
              ],
            ),
          ),

          // Editing Controls
          Container(
            height: 60,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: Icon(Icons.cut), onPressed: () {}),
                IconButton(icon: Icon(Icons.music_note), onPressed: () {}),
                IconButton(icon: Icon(Icons.text_fields), onPressed: () {}),
                IconButton(icon: Icon(Icons.photo_filter), onPressed: () {}),
                IconButton(icon: Icon(Icons.adjust), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _addMedia,
        child: Icon(Icons.add),
      ),*/
    );
  }

}





Future<void> showThumbnailDialog(BuildContext context, List<Uint8List?> thumbnails) async {
  print("Showing thumbnail dialog...");

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Test Dialog"),
        content: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // 5 thumbnails per row, adjust as needed
          ),
          itemCount: thumbnails.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                // Handle thumbnail selection here
                Navigator.of(context).pop(thumbnails[index]);
              },
              child: Image.memory(thumbnails[index]!),
            );
          },
        ),
      );
    },
  );
}


Future<List<Uint8List?>> _generateMultipleThumbnails(String videoPath) async {
  final VideoPlayerController controller = VideoPlayerController.file(File(videoPath));
  await controller.initialize();

  final double totalDurationSeconds = controller.value.duration.inSeconds.toDouble();

  final double interval = totalDurationSeconds / 101;  // Adjusted for 100 thumbnails
  List<Uint8List?> thumbnails = [];

  for (int i = 1; i <= 100; i++) {  // Looping 100 times
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.PNG,
      timeMs: (interval * i * 1000).toInt(),
      maxWidth: 128,
      quality: 25,
    );
    thumbnails.add(uint8list);
  }
  print("Generating multiple thumbnails...${thumbnails}");

  return thumbnails;
}

Future<Uint8List?> _generateThumbnail(String videoPath) async {
  final uint8list = await VideoThumbnail.thumbnailData(
    video: videoPath,
    imageFormat: ImageFormat.PNG,
    maxWidth: 128,
    quality: 25,
  );
  return uint8list;
}

Future<Uint8List?> _chooseThumbnail(BuildContext context, String videoPath) async {
  final List<Uint8List?> thumbnails = await _generateMultipleThumbnails(videoPath);
  Uint8List? chosenThumbnail;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
          ),
          itemCount: thumbnails.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                chosenThumbnail = thumbnails[index];
                Navigator.of(context).pop();
              },
              child: Image.memory(thumbnails[index]!),
            );
          },
        ),
      );
    },
  );
  return chosenThumbnail;
}
