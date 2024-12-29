import 'package:dio/dio.dart';
import 'package:self_code/api/token_handler.dart';
import '../main.dart';

Future<void> postComment(String postId, String commentText) async {
  final Dio _dio = Dio();
  final TokenHandler _tokenApiKeeper = getIt<TokenHandler>();
  final String authToken = await _tokenApiKeeper.getAccessToken();
  final String apiUrl = 'https://neurotune.de/api/posts/$postId/comment/';

  try {
    final response = await _dio.post(
      apiUrl,
      data: {'description': commentText},
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );

    if (response.statusCode == 201) {
      print("Comment posted successfully");
    } else {
      print("Failed to post comment. Status code: ${response.statusCode}");
    }
  } catch (error) {
    print("Error posting comment: $error");
  }
}
