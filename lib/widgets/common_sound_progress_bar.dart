import 'dart:ui';

import 'package:flutter/material.dart';


class ProgressBar extends StatefulWidget {
  final Duration duration;
  final List<Duration> fileDurations;
  final double initialProgress;
  final Function(Duration) onBulletDrop;
  final double width;
  final double height;
  final Stream<Duration> currentPosition; // Added currentPosition stream
  final num lengthOfPreviousAudioFiles;

  const ProgressBar({super.key,
    required this.duration,
    required this.fileDurations,
    this.initialProgress = 0.0,
    required this.onBulletDrop,
    required this.width,
    required this.height,
    required this.currentPosition,
    required this.lengthOfPreviousAudioFiles,
  });

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  Duration _currentTime = Duration.zero;
  double _bulletPosition = 0.0;
  bool isDragged = false;
  int _currentTimeInMs = 0;
  int bulletUpdateCounter = 0;
  double dragBlur = 0;
  Duration globalPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.duration * widget.initialProgress;
  }

  void _showAlertBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bullet Point Dropped'),
        content: Text('Dropped at ${_formatDuration(_currentTime)}'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    ;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 30),
        StreamBuilder<Duration>(
          stream: widget.currentPosition,
          initialData: Duration.zero,
          builder: (context, snapshot) {
            final currentPosition = snapshot.data!;
            final double currentProgress =
                currentPosition.inMilliseconds / widget.duration.inMilliseconds;

            if ( (currentPosition.inMilliseconds + widget.lengthOfPreviousAudioFiles.toInt()) <= widget.duration.inMilliseconds) {
            globalPosition = Duration(milliseconds: currentPosition.inMilliseconds + widget.lengthOfPreviousAudioFiles.toInt());
            }
            if (bulletUpdateCounter == 0) {
              if (!isDragged) {
                _bulletPosition = (currentProgress + (widget.lengthOfPreviousAudioFiles / widget.duration.inMilliseconds));
                if (_bulletPosition > 1){
                  _bulletPosition = 1;
                }
                isDragged = false;
              }
            }else {
              bulletUpdateCounter -=1;
            }

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                color: Colors.transparent,
              ),
              child: Stack(
                children: [
                  GestureDetector(
                    onTapDown: (details) {
                      // Calculate the new bullet position based on the tap position
                      final newBulletPosition = details.localPosition.dx / widget.width;
                      setState(() {
                        isDragged = true;
                        dragBlur = 3;
                        _bulletPosition = newBulletPosition.clamp(0.0, 1.0);
                        _currentTime = widget.duration * _bulletPosition;
                        _currentTimeInMs = _currentTime.inMilliseconds;
                      });
                    },
                    onTapUp: (details) {
                      // Calculate the new bullet position based on the tap position
                      final newBulletPosition = details.localPosition.dx / widget.width;
                      setState(() async {
                        isDragged = true;
                        dragBlur = 3;
                        _bulletPosition = newBulletPosition.clamp(0.0, 1.0);
                        _currentTime = widget.duration * _bulletPosition;
                        _currentTimeInMs = _currentTime.inMilliseconds;
                        dragBlur = 0;
                        bulletUpdateCounter = 3;
                        await widget.onBulletDrop(_currentTime);
                        isDragged = false;
                        print('_currentTime: $_currentTime');
                      });
                    },
                    child: Container(
                      height: widget.height + 80,
                      width: widget.width + widget.height + 5,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(widget.height),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        height: 10,

                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(widget.height),

                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 45,
                    child: GestureDetector(
                      onTapDown: (details) {
                        // Calculate the new bullet position based on the tap position
                        final newBulletPosition = details.localPosition.dx / widget.width;
                        setState(() {
                          isDragged = true;
                          dragBlur = 3;
                          _bulletPosition = newBulletPosition.clamp(0.0, 1.0);
                          _currentTime = widget.duration * _bulletPosition;
                          _currentTimeInMs = _currentTime.inMilliseconds;
                        });
                      },
                      onTapUp: (details) {
                        // Calculate the new bullet position based on the tap position
                        final newBulletPosition = details.localPosition.dx / widget.width;
                        setState(() async {
                          isDragged = true;
                          dragBlur = 3;
                          _bulletPosition = newBulletPosition.clamp(0.0, 1.0);
                          _currentTime = widget.duration * _bulletPosition;
                          _currentTimeInMs = _currentTime.inMilliseconds;
                          dragBlur = 0;
                          bulletUpdateCounter = 3;
                          await widget.onBulletDrop(_currentTime);
                          isDragged = false;
                          print('_currentTime: $_currentTime');
                        });
                      },
                      child: Container(
                        height: 10,
                        width: widget.width * _bulletPosition + 25,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[300],
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(widget.height / 2),
                            right: Radius.circular(widget.height / 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: widget.width * _bulletPosition - 10,
                    top: 0,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        //Changed _bulletPosition to currentProgress
                        final newBulletPosition = _bulletPosition + details.primaryDelta! / widget.width;
                        if (newBulletPosition.isFinite) {
                          setState(() {
                            isDragged = true;
                            dragBlur = 3;
                            //removed .clamp(0.0, 1)
                            _bulletPosition = newBulletPosition.clamp(0.0, 1);
                            _currentTime = widget.duration * _bulletPosition;
                            _currentTimeInMs = _currentTime.inMilliseconds;
                          });
                        } else {
                          // Handle non-finite value (e.g., show an error message or perform appropriate action)
                        }
                      },
                      onHorizontalDragEnd: (details) async {
                        dragBlur = 0;
                        bulletUpdateCounter = 3;
                        await widget.onBulletDrop(_currentTime);
                        isDragged = false;
                        print('_currentTime: $_currentTime');

                      },

                      child: Container(
                        width: widget.height + 25,
                        height: widget.height + 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0),
                          shape: BoxShape.circle,
                        ), child: Center(

                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              radius: 0.7,
                              colors: [
                            Colors.white,
                            Colors.deepPurple,
                            ],
                              stops: [0.0, 0.9],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withAlpha(100),
                                blurRadius: 1,
                                spreadRadius: dragBlur,
                                offset: Offset(0.0,0.0,),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),
                    ),
                  ),
                  Container(
                    width: 355,
                    child: Row(
                      children: [
                        Text('${_formatDuration(globalPosition)}'),

                        Spacer(),
                        Text('${_formatDuration(widget.duration)}'
                        )

                      ],
                    ),
                  )

                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
