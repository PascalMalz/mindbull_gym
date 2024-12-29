import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';


class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  String _filePath = '';
  List<int> _audioSamples = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    if (!_isRecording) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      _filePath = '${appDocDir.path}/recording.wav';
      _audioSamples.clear();
      setState(() {
        _isRecording = true;
      });
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      await SystemSound.play(SystemSoundType.click);
      await _saveRecording();
    }
  }

  Future<void> _saveRecording() async {
    final file = File(_filePath);
    await file.writeAsBytes(_audioSamples);
  }

  void _onAudioSampleReceived(List<int> samples) {
    setState(() {
      _audioSamples.addAll(samples);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 200.0,
              width: double.infinity,
              color: Colors.grey,
              child: CustomPaint(
                painter: WaveformPainter(samples: _audioSamples),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
          ],
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<int> samples;

  WaveformPainter({required this.samples});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (samples.isNotEmpty) {
      final width = size.width / samples.length;
      path.moveTo(0, size.height / 2);
      for (var i = 0; i < samples.length; i++) {
        final x = i * width;
        final y = samples[i] / 128 * size.height / 2;
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.samples != samples;
  }
}
