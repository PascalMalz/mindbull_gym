import 'package:dio/dio.dart';
import 'package:self_code/api/token_handler.dart';
import '../main.dart';
import '../models/post.dart';

class ApiLikePost {
  final Dio _dio = Dio();
  final TokenHandler _tokenApiKeeper = getIt<TokenHandler>(); // Use getIt to get the instance


  // Function to check if the current user has liked a post
  Future<bool> checkLikeStatus(String postId) async {
    final String authToken = await _tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/posts/$postId/check_like/';
    print('check like status performing');
    final Response response = await _dio.get(
      apiUrl,
      options: Options(
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      print('response.data: $data');
      return data['is_liked_by_user'];

    } else {
      throw Exception('Failed to check like status');
    }
  }

  Future<void> likePost(String postId) async {
    final String authToken = await _tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/posts/$postId/like/';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
    };

    try {
      final Response response = await _dio.post(
        apiUrl,
        options: Options(headers: headers),
      );

      if (response.statusCode == 204) {
        // Assuming a 204 No Content response for a successful like
        print("Post liked successfully");
      } else {
        // Handle other statuses appropriately
        print("Failed to like the post. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle any errors that occur during the request
      print("Failed to like the post: $error");
    }
  }
  // Function to fetch posts liked by the current user
  Future<List<Post>> getLikedPosts(String userId) async {
    final String authToken = await _tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/users/$userId/liked_posts/';

    try {
      final Response response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );
      print("getLikedPosts: response: $response"); // Debugging statement

      if (response.statusCode == 200) {
        // Check if the data structure is as expected
        var responseData = response.data;
        if (responseData is List) {
          List<Post> posts = responseData.map((data) {
            print("Post data: ${data}");  // Log each post data before parsing
            return Post.fromJson(data as Map<String, dynamic>);
          }).toList();
          return posts;
        } else {
          print("Error: Expected a list but got ${responseData.runtimeType}");
          return []; // Return an empty list if data is not a list
        }
      } else {
        print("Failed to fetch liked posts. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Failed to fetch liked posts: $error");
      return [];
    }
  }

}
