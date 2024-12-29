import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/post.dart'; // Assuming Post model is defined
import 'dart:io';

class APIListCompositionPostService {
  static final Dio dio = Dio();

  static Future<List<Post>> fetchPosts() async {
    try {
      var response = await dio.get('https://neurotune.de/api/compositions/'); // Adjust URL
      print("APIListCompositionPostService fetchPosts Raw response data: ${response.data}");

      // Get the document directory for the app.
      Directory docDir = await getApplicationDocumentsDirectory();
      String path = '${docDir.path}/composition_response_data.txt';
      print('${docDir.path}');

      // Write response to a file
      File file = File(path);
      await file.writeAsString(response.data.toString(), mode: FileMode.write);
      print('APIListCompositionPostService fetchPosts response.statusCode ${response.statusCode}');
      if (response.statusCode == 200) {
        var responseData = response.data;
        print("APIListCompositionPostService fetchPosts Response data: $responseData");

        if (responseData is List) {
          return responseData.map((data) {
            print("Post data with composition: $data");
            return Post.fromJson(data as Map<String, dynamic>); // Adjust based on your Post model
          }).toList();
        } else {
          print("Error: Response data is not a List");
          return [];
        }
      } else {
        throw Exception('Failed to load posts with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts with compositions: $e');
      return [];
    }
  }
}
