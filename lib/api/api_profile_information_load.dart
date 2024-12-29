import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:self_code/api/token_handler.dart';
import '../main.dart';

class ApiUserProfile {
  final Dio _dio = Dio();
  final TokenHandler tokenApiKeeper = getIt<TokenHandler>(); // Use getIt to get the instance

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final String authToken = await tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/sum/api/user-profile/';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      // Add any other headers like Content-Type if necessary
    };

    try {
      final Response response = await _dio.get(
        apiUrl,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.data);
        return userData;
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      throw Exception('Failed to load user profile: $error');
    }
  }
}
