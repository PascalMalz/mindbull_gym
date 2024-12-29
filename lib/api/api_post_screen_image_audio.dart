

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:self_code/api/token_handler.dart';

import '../main.dart';

class ApiPostScreenImageAudio {
  final Dio _dio = Dio();
  final TokenHandler tokenApiKeeper = getIt<TokenHandler>();

  Future<String?> uploadPostWithMedia(File imageFile, File audioFile, String content, List<String> tags, int durationInMilliseconds) async {
    final String authToken = await tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/post-with-audio-image/'; // Update with your API URL

    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $authToken',
    };

    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: 'post_image.jpg'),
        'audio': await MultipartFile.fromFile(audioFile.path, filename: 'post_audio.mp3'),
        'description': content,
        'tags': json.encode(tags),
        'duration_in_milliseconds': durationInMilliseconds,
      });

      final Response response = await _dio.post(apiUrl, data: formData, options: Options(headers: headers));
      print('response.statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        return null; // Post with media uploaded successfully
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (error) {
      return 'Exception: $error';
    }
  }
}
