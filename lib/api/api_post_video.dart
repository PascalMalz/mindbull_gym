import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:self_code/api/token_handler.dart';

import '../main.dart';

class ApiPostScreenVideo {
  final Dio _dio = Dio();
  final TokenHandler tokenApiKeeper = getIt<TokenHandler>();

  Future<String?> uploadVideo(File videoFile, String description, List<String> tags) async {
    final String authToken = await tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/post-video/'; // Update with your API URL

    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $authToken',
    };

    try {
      FormData formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(videoFile.path, filename: 'post_video.mp4'),
        'description': description,
        'tags': json.encode(tags),
      });

      final Response response = await _dio.post(apiUrl, data: formData, options: Options(headers: headers));
      print('Response statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        return null; // Video uploaded successfully
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (error) {
      return 'Exception: $error';
    }
  }
}
