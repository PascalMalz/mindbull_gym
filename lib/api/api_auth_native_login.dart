//todo is it ok to pass the password unencrypted?
//todo handle not verified users

import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:self_code/api/token_handler.dart';

import '../clear_user_data_processes.dart';


class ApiAuthNativeLogin {
  final Dio _dio = Dio();

  final TokenHandler tokenApiKeeper; // Add a field for TokenApiKeeperValidator

  // Modify the constructor to accept TokenApiKeeperValidator
  ApiAuthNativeLogin(this.tokenApiKeeper);

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final String apiUrl = 'https://neurotune.de/sum/api/login/'; // Replace with your API endpoint
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
    };

    try {
      final Response response = await _dio.post(
        apiUrl,
        data: jsonEncode(requestBody),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print('ApiAuthNativeLogin: logged in successful with ${response.data.toString()}');

        // Store the access token using the TokenApiKeeperValidator
        final Map<String, dynamic> responseData = response.data;
        final String accessToken = responseData['access'] ?? '';
        final String refreshToken = responseData['refresh'] ?? '';
        tokenApiKeeper.setRefreshToken(refreshToken); // Store the refresh token
        tokenApiKeeper.setAccessToken(accessToken); // Store the access token
        print('ApiAuthNativeLogin: User authenticated with native login. accessToken: $accessToken, refreshToken: $refreshToken ');
        ClearUserDataProcess().clearJobs();
        tokenApiKeeper.registerLogin();
        return response.data; // Return the response data directly
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: apiUrl), // Provide the RequestOptions
          response: response,
          error: 'ApiAuthNativeLogin: Backend request failed with status code ${response.statusCode}',
        );
      }
    } catch (error) {
      List<String> errorArray = ['message', 'Wrong email or password.'];
      Map<String, dynamic> errorMap = {
        errorArray[0]: errorArray[1],
      };
      return errorMap;
    }
  }
}
