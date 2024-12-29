// Filename: lib/screens/generic_post_screen.dart
// A Flutter page to create multimedia posts with navigation controls for media playback.

import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:self_code/widgets/button_widget.dart';
import 'package:video_player/video_player.dart';

class GenericPostScreen extends StatefulWidget {
  @override
  _GenericPostScreenState createState() => _GenericPostScreenState();
}

class _GenericPostScreenState extends State<GenericPostScreen> {
  VideoPlayerController? _videoController;
  AudioPlayer _audioPlayer = AudioPlayer();
  List<File> _mediaFiles = [];
  bool isVideoPlaying = false;
  bool isAudioPlaying = false;
  Duration _videoPosition = Duration.zero;
  Duration _audioPosition = Duration.zero;
  Timer? _timer;
  bool _isFullScreen = false;
  List<MediaTrack> _tracks = [];

  @override
  void initState() {
    super.initState();
    _audioPlayer.positionStream.listen((position) => setState(() => _audioPosition = position));
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context); // Initialize ScreenUtil
    return Scaffold(
      //backgroundColor: Colors.grey.shade900,
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('Media Playback'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _videoController != null && _videoController!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
                : Container(
              height: 200,
              color: Colors.black12,
              child: Center(child: Text('Select a video to play')),
            ),
            if (_videoController != null)
              VideoProgressIndicator(_videoController!,padding: EdgeInsets.all(20), allowScrubbing: true,
                colors: VideoProgressColors(
                playedColor: Colors.deepPurple,      // Color for the played portion
                bufferedColor: Colors.white, // Color for the buffered portion
                backgroundColor: Colors.grey, // Color for the background
              ),),
            // Video control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(isVideoPlaying ? Icons.pause : Icons.play_arrow, size: 50,color: Colors.white,),
                  onPressed: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                        isVideoPlaying = false;
                      } else {
                        _videoController!.play();
                        isVideoPlaying = true;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.stop, size: 50,color: Colors.white,),
                  onPressed: () {
                    _videoController!.pause();
                    _videoController!.seekTo(Duration.zero);
                    setState(() {
                      isVideoPlaying = false;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.fast_rewind, size: 50,color: Colors.white,),
                  onPressed: () {
                    _seekVideo(isForward: false);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.fast_forward, size: 50,color: Colors.white,),
                  onPressed: () {
                    _seekVideo(isForward: true);
                  },
                ),
                // Full-screen toggle button
                IconButton(
                  icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, size: 50,color: Colors.white,),
                  onPressed: _toggleFullScreen,
                ),


              ],
            ),
            // Audio control buttons (similar to video controls)
            // Implement similar control buttons for the audio player
            Column(
              children: _tracks
                  .asMap()
                  .entries
                  .map((entry) => _buildTrackItem(entry.value, entry.key))
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: IconButton(onPressed: _addMedia, icon: Icon(Icons.add_circle_rounded, size: 50,color: Colors.white,)),
            )
          ],
        ),
      ),
    );
  }

  // Video player methods
  void _playVideo(File videoFile) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
        _startVideoPositionListener();
      });
    setState(() {
      isVideoPlaying = true;
    });
  }

  void _startVideoPositionListener() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _videoPosition = _videoController!.value.position;
      });
    });
  }

  // Audio player methods
  void _playAudio(File audioFile) async {
    await _audioPlayer.setFilePath(audioFile.path);
    await _audioPlayer.play();
    setState(() {
      isAudioPlaying = true;
    });
  }

  void _addMedia() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any, // Change to FileType.media if you want to restrict to media files only
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        List<Duration> durations = [];

        for (File file in files) {
          Duration duration = await _getMediaDuration(file);
          durations.add(duration);
        }

        setState(() {
          _tracks.add(MediaTrack(mediaFiles: files, mediaDurations: durations));
        });
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }


  void _seekVideo({required bool isForward}) {
    final currentPosition = _videoController!.value.position;
    final duration = _videoController!.value.duration;
    final skipDuration = Duration(seconds: 10);
    if (isForward) {
      _videoController!.seekTo(currentPosition + skipDuration > duration
          ? duration
          : currentPosition + skipDuration);
    } else {
      _videoController!.seekTo(currentPosition - skipDuration < Duration.zero
          ? Duration.zero
          : currentPosition - skipDuration);
    }
  }


  void _toggleFullScreen() {
    if (_isFullScreen) {
      // Exit full-screen mode
      Navigator.pop(context); // Close the full-screen page
      setState(() => _isFullScreen = false);
    } else {
      // Enter full-screen mode
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FullScreenVideoPlayerScreen(_videoController)),
      ).then((_) {
        setState(() => _isFullScreen = false);
      });
      setState(() => _isFullScreen = true);
    }
  }

  Widget _buildTrackItem(MediaTrack track, int trackIndex) {
    final double trackWidth = MediaQuery.of(context).size.width;
    final Duration oneHour = Duration(hours: 1);
    final double oneHourInMilliseconds = oneHour.inMilliseconds.toDouble();

    return Column(
      children: [
        ListTile(
          title: Text('Track ${trackIndex + 1}'),
          subtitle: Text('Contains ${track.mediaFiles.length} media items'),
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addMediaToTrack(trackIndex),
          ),
        ),
        DragTarget<int>(
          onWillAccept: (data) => true,
          onAcceptWithDetails: (DragTargetDetails<int> details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final Offset localOffset = renderBox.globalToLocal(details.offset);
            final double dropPosition = localOffset.dx;

            setState(() {
              track.mediaPositions[details.data] = dropPosition / trackWidth;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Stack(
              children: track.mediaDurations.asMap().entries.map((entry) {
                final double widthRatio = entry.value.inMilliseconds / oneHourInMilliseconds;
                final double itemWidth = trackWidth * widthRatio;
                final double leftPosition = track.mediaPositions.isNotEmpty
                    ? track.mediaPositions[entry.key] * trackWidth
                    : 0;

                return Positioned(
                  left: leftPosition,
                  child: Draggable(
                    data: entry.key,
                    child: Container(
                      width: itemWidth,
                      height: 50,
                      color: Colors.deepPurple,
                      alignment: Alignment.center,
                      child: Text(_formatDuration(entry.value), style: TextStyle(color: Colors.white)),
                    ),
                    feedback: Material(
                      child: Container(
                        width: itemWidth,
                        height: 50,
                        color: Colors.deepPurple.withOpacity(0.7),
                        alignment: Alignment.center,
                        child: Text(_formatDuration(entry.value), style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }


  Widget _buildMediaItem(File file, Duration duration, int trackIndex, int mediaIndex, Key key) {
    return LongPressDraggable<int>(
      key: key, // Assign the key here
      data: mediaIndex,
      child: _mediaItem(file, duration),
      feedback: Material(
        child: _mediaItem(file, duration), // This is what is shown when dragging
        elevation: 4.0,
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex, int trackIndex, MediaTrack track) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = track.mediaFiles.removeAt(oldIndex);
      final duration = track.mediaDurations.removeAt(oldIndex);
      track.mediaFiles.insert(newIndex, item);
      track.mediaDurations.insert(newIndex, duration);
    });
  }

  void _addNewTrack() {
    setState(() {
      _tracks.add(MediaTrack());
    });
  }

  Future<void> _addMediaToTrack(int trackIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      List<Duration> durations = [];

      for (var file in files) {
        Duration duration = await _getMediaDuration(file);
        durations.add(duration);
      }

      // Now that all durations are fetched, update the state
      setState(() {
        _tracks[trackIndex].mediaFiles.addAll(files);
        _tracks[trackIndex].mediaDurations.addAll(durations);
      });
    }
  }





}

class MediaTrack {
  List<File> mediaFiles;
  List<Duration> mediaDurations;
  List<double> mediaPositions; // Add this list to store positions

  MediaTrack({
    this.mediaFiles = const [],
    this.mediaDurations = const [],
    this.mediaPositions = const [], // Initialize in the constructor
  });
}



// FullScreenVideoPlayerScreen
class FullScreenVideoPlayerScreen extends StatelessWidget {
  final VideoPlayerController? controller;

  FullScreenVideoPlayerScreen(this.controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      ),
    );
  }
}



Widget _mediaItem(File file, Duration duration) {
  // Your existing method to build the media item
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        file.path.endsWith('.mp4') ? Icon(Icons.videocam) : Icon(Icons.audiotrack),
        Text(_formatDuration(duration), style: TextStyle(fontSize: 12)),
      ],
    ),
  );
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}


Future<Duration> _getMediaDuration(File file) async {
  if (file.path.endsWith('.mp4')) {
    // Handling video files
    final VideoPlayerController controller = VideoPlayerController.file(file);
    await controller.initialize();
    Duration duration = controller.value.duration;
    controller.dispose();
    return duration;
  } else if (file.path.endsWith('.mp3')) {
    // Handling audio files
    final AudioPlayer player = AudioPlayer();
    await player.setFilePath(file.path);
    Duration? duration = await player.duration;
    player.dispose();
    return duration ?? Duration.zero;
  }
  return Duration.zero; // Default duration if type not supported or no metadata
}