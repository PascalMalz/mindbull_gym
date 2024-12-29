// Filename: api_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';

class ApiFeedService {
  int page = 1;
  Dio dio = Dio();

  Future<List<dynamic>> fetchMorePosts() async {
    Response response;

    try {
      response = await dio.get('https://neurotune.de/api/posts?page=$page');
      print('ApiFeedService fetchMorePosts response.statusCode ${response.statusCode}');
      if (response.statusCode == 200) {
        page++;
        print('ApiFeedService jsonDecode(response.data): ${response.data}');
        return List<dynamic>.from(response.data['results']);
      } else {
        print('Failed to load posts');
        return [];
      }
    } catch (e) {
      print('Failed to load posts: $e');
      return [];
    }
  }
}