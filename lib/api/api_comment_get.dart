import 'package:dio/dio.dart';
import 'package:self_code/models/comment.dart'; // Update this import based on your project structure
import 'package:self_code/api/token_handler.dart'; // Assuming you have a way to handle tokens
import '../main.dart';

class ApiCommentGet {
  final Dio _dio = Dio();

  Future<List<Comment>> fetchComments(String postId) async {
    final TokenHandler tokenApiKeeper = getIt<TokenHandler>(); // Use getIt to get the instance
    final String authToken = await tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/api/posts/$postId/comments/';

    final response = await _dio.get(
      apiUrl,
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    print('ApiCommentGet fetchComments response $response');
    if (response.statusCode == 200) {
      List<dynamic> commentsJson = response.data;
      return commentsJson.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }
}
