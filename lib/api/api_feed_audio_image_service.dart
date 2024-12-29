// Filename: api_feed_audio_image_service.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:self_code/api/token_handler.dart';
import '../main.dart';
import '../models/post.dart';
import 'dart:io';

//path for the response data:/data/data/de.mindbull.mindbull/app_flutter/response_data.txt

class ApiFeedAudioImageService {
  static final Dio dio = Dio();
  final TokenHandler tokenApiKeeper = getIt<TokenHandler>(); // Use getIt to get the instance



  // Updated fetchPosts method to include multiple optional filtering parameters
  Future<List<Post>> fetchPosts({
    String? userId,
    List<String>? tags,
    String? category,
    String? characteristics,
  }) async {

    try {
      final String accessToken = await tokenApiKeeper.getAccessToken();
      String baseUrl = 'https://neurotune.de/api/posts-audio-image/';
      Map<String, dynamic> queryParameters = {};

      // Dynamically add filters to the queryParameters map if they are not null
      if (userId != null) queryParameters['user_id_backend_post'] = userId;
      if (tags != null && tags.isNotEmpty) queryParameters['tags'] = tags.join(',');
      // Note: Adjust the parameter names to match your API's expected query parameters
      if (category != null) queryParameters['category'] = category;
      if (characteristics != null) queryParameters['characteristics'] = characteristics;
      print('ApiFeedAudioImageService fetchPosts queryParameters $queryParameters');

      // Include the Authorization header with the accessToken
      var response = await dio.get(
          baseUrl,
          queryParameters: queryParameters.isEmpty ? null : queryParameters,
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}) // Set the header with the token
      );

      print("Raw response data: ${response.data}");  // Log the entire raw response

      // Get the document directory for the app
      Directory docDir = await getApplicationDocumentsDirectory();
      String path = '${docDir.path}/response_data.txt';
/*      // Write response to a file
      File file = File(path);
      await file.writeAsString(response.data.toString(), mode: FileMode.write);*/

      if (response.statusCode == 200) {
        var responseData = response.data;
        print("Response data: $responseData");  // Log the parsed response data

        if (responseData is List) {
          return responseData.map((data) {
            print("Post data: $data");  // Log each post data before parsing
            return Post.fromJson(data as Map<String, dynamic>);
          }).toList();
        } else {
          print("Error: Response data is not a List");
          return [];
        }
      } else {
        throw Exception('Failed to load posts with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }
}