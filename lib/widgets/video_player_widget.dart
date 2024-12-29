import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerWidget extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;

  VideoPlayerWidget({Key? key, this.videoFile, this.videoUrl})
      : assert(videoFile != null || videoUrl != null, 'A video file or a video URL must be provided.'),
        super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    print('init VideoPlayerWidget');
    super.initState();
    _initVideoPlayer();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoFile != oldWidget.videoFile || widget.videoUrl != oldWidget.videoUrl) {
      _reinitializeVideoPlayer();
    }
  }

  void _initVideoPlayer() {
    _controller = widget.videoFile != null
        ? VideoPlayerController.file(widget.videoFile!)
        : VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!)); // Use Uri.parse for String URLs

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    });
  }


  Future<void> _reinitializeVideoPlayer() async {
    await _controller.pause();
    await _controller.dispose();

    setState(() {
      _initVideoPlayer();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Calculate the maximum available size for the video player
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = 550.0; // Fixed height as mentioned
    final maxWidth = screenWidth - 60; // Subtract left and right padding
    final maxHeight = screenHeight - 10; // Subtract top and bottom padding

    // Assuming the video player uses the full width to calculate its height
    final targetAspectRatio = _controller.value.aspectRatio;
    double targetWidth = maxWidth;
    double targetHeight = targetWidth / targetAspectRatio;

    // Adjust dimensions if the calculated height exceeds maxHeight
    if (targetHeight > maxHeight) {
      targetHeight = maxHeight;
      targetWidth = targetHeight * targetAspectRatio;
    }

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && _controller.value.isInitialized) {
          // Wrap the AspectRatio widget in a Container with a black background
          return Center(
            child: Container(
              width: maxWidth, // Use the maximum width available
              height: maxHeight, // Use the maximum height available
              color: Colors.transparent, // Fill the background with black color
              child: Center(
                child: AspectRatio(
                  aspectRatio: targetAspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller), // The video player
                      _ControlsOverlay(controller: _controller), // Reintegrated overlay controls
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // While loading, show a spinner
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }


}

class _ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  @override
  _ControlsOverlayState createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  double _sliderValue = 0.0;
  bool _isInteracting = false;
  bool _hasBeenPlayed = false;  // To track if the video has been played once.

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.value.isInitialized && mounted) {
        setState(() {
          _sliderValue = widget.controller.value.position.inMilliseconds.toDouble();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.controller.value.isPlaying;
    final isInitialized = widget.controller.value.isInitialized;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        // Invisible GestureDetector for the whole video area
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (!_isInteracting) {  // Only toggle play/pause when not interacting with the slider
                if (isPlaying) {
                  widget.controller.pause();
                } else {
                  widget.controller.play();
                  _hasBeenPlayed = true; // Set this when the video is played for the first time
                }
              }
            },
          ),
        ),
        // Show the play button only when the video hasn't been played yet
        if (isInitialized && !_hasBeenPlayed)
          Center(
            child: IconButton(
              iconSize: 100.0,
              icon: Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () {
                widget.controller.play();
                setState(() {
                  _hasBeenPlayed = true; // Ensure this is only shown once
                });
              },
            ),
          ),
        if (isInitialized)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10 ,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
              ),
              child: Slider(
                value: _sliderValue,
                min: 0.0,
                max: widget.controller.value.duration.inMilliseconds.toDouble(),
                onChangeStart: (_) {
                  _isInteracting = true; // Mark that the user is interacting with the slider
                },
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
                onChangeEnd: (value) {
                  widget.controller.seekTo(Duration(milliseconds: value.toInt()));
                  _isInteracting = false; // Mark that the user has finished interacting with the slider
                },
                activeColor: Colors.deepPurple,
                inactiveColor: Colors.grey.shade300,
              ),
            ),
          ),
      ],
    );
  }
}
