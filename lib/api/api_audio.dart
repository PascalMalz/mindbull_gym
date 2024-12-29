

//todo some files get broken after upload no thumbnail and not playable from android. Even if file is downloaded directly from server with ftp it is received there already broken. Wrote an bug report in dio library on github

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:http_parser/http_parser.dart';
import 'package:self_code/api/token_handler.dart';
import '../main.dart';
import '../models/audio.dart';

class ApiAudio {
  final String baseUrl = 'https://neurotune.de/';
  final String apiUrl = 'https://neurotune.de/api/upload_music/';
  late final Dio _dio;
  final CookieJar _cookieJar = CookieJar(); // Store the cookieJar as an instance variable
  final TokenHandler tokenApiKeeper = getIt<TokenHandler>(); // Use getIt to get the instance
  ApiAudio() {
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    _dio = Dio();
    _dio.interceptors.add(CookieManager(_cookieJar));
    // Additional Dio initialization, if needed
  }
  Future<void> init() async {
    await _initializeDio();
  }

  Future<void> uploadMusic({
    required File musicFile,
    required String userName,
    required String customFileName,
    required List<String> tags,
    required void Function(double) onProgress,
    required void Function() onSuccess,
    required void Function(String) onError,
  }) async {
    FormData formData = FormData.fromMap({
      'music': await MultipartFile.fromFile(
        musicFile.path,
        filename: musicFile.path
            .split('/')
            .last,
        contentType: MediaType('audio', 'mpeg'),
      ),
      'tags': tags.join(','),
      'username': userName,
      'timestamp': DateTime.now().toUtc().toString(),
      'custom_file_name': customFileName,
    });


      final String authToken = await tokenApiKeeper.getAccessToken();

      final Map<String, String> headers = {
        'Authorization': 'Bearer $authToken',
        // Add any other headers like Content-Type if necessary
      };

    try {
      Response response = await _dio.post(
        apiUrl,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (int sent, int total) {
          double progress = ((sent / total) * 100.0).clamp(0.0, 100.0);
          print(progress);
          onProgress(progress);
        },
      );

      if (response.statusCode == 200) {
        onSuccess();
      } else {
        onError('Error uploading music file: ${response.statusMessage}');
      }
    } catch (e) {
      onError('Error uploading music file: $e');
    }
  }

  Future<List<Audio>> fetchAudioFilesForCategory(
      String categoryName) async {
    try {
      final dio = Dio();
      final response = await dio.get('$baseUrl/audioFiles/$categoryName');
      if (response.statusCode == 200) {
        final jsonData = response.data as List;
        final List<Audio> audioFiles =
        jsonData.map((data) => Audio.fromJson(data)).toList();
        return audioFiles;
      } else {
        throw Exception('Failed to fetch audio files');
      }
    } catch (e) {
      print('Error fetching audio files for category: $e');
      return [];
    }
  }
  Future<void> deleteMusic(String musicId, String fileName,
      {required void Function() onSuccess, required void Function(String) onError}) async {
    try {
      final cookies = await _cookieJar.loadForRequest(Uri.parse(baseUrl));
      print('All cookies: $cookies'); // Print all retrieved cookies

      final csrfCookie = cookies.firstWhere(
            (cookie) => cookie.name == 'csrftoken',
        orElse: () => Cookie('csrftoken', ''), // Provide a default empty cookie
      );

      print('CSRF cookie: $csrfCookie'); // Print the CSRF token cookie

      if (csrfCookie.value.isEmpty) {
        onError('CSRF token not found');
        return;
      }

      final csrfToken = csrfCookie.value;

      // Delete record from the database
      final deleteResponse = await _dio.delete(
        '$baseUrl/$musicId',
        options: Options(
          headers: {
            'X-CSRFToken': csrfToken,
          },
        ),
      );

      if (deleteResponse.statusCode == 200) {
        // Delete associated file
        final file = File(fileName);
        if (await file.exists()) {
          await file.delete();
        }

        onSuccess(); // Call the success callback
      } else {
        onError('Error deleting music: ${deleteResponse.statusMessage}');
      }
    } catch (e) {
      onError('Error deleting music: $e');
    }
  }
}