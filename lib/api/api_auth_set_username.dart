import 'package:dio/dio.dart';
import 'package:self_code/api/token_handler.dart';

class ApiAuthSetUsername {
  final Dio _dio = Dio();

  final TokenHandler tokenApiKeeper;

  ApiAuthSetUsername(this.tokenApiKeeper);

  Future<String?> setUsername(String username) async {
    final authToken = tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://your-django-api-url.com/set_username/';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken', // Include your authentication token
    };
    final Map<String, dynamic> requestBody = {
      'username': username,
    };

    try {
      final Response response = await _dio.post(
        apiUrl,
        data: requestBody,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return null; // Username set successfully
      } else if (response.statusCode == 400) {
        return 'Username is already taken';
      } else if (response.statusCode == 401) {
        return 'Unauthorized'; // Handle unauthorized access if needed
      } else {
        return 'Backend request failed with status code ${response.statusCode}';
      }
    } catch (error) {
      return 'Please try again later.';
      //return 'Dio error: $error';
    }
  }
}
