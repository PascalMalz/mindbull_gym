//API to register from Flutter without social auth in Django
//todo after click on email link forward to app maybe no link but a code would be better
import 'package:dio/dio.dart';
import 'package:self_code/api/token_handler.dart';
import 'dart:convert';

import '../models/user.dart';



class ApiAuthNativeRegistration {
  final Dio _dio = Dio();


  final TokenHandler tokenApiKeeper;

  ApiAuthNativeRegistration(this.tokenApiKeeper);

  Future<String?> registerUser(String email, String password,String username) async {
    final String apiUrl = 'https://neurotune.de/sum/api/register/';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
      'username': username
    };

    try {
      final Response response = await _dio.post(
        apiUrl,
        data: jsonEncode(requestBody),
        options: Options(headers: headers),
      );

      if (response.statusCode == 201) {
        // If registration is successful, you may want to set access and refresh tokens here
        // Based on your backend's response structure
        final Map<String, dynamic> responseData = response.data;
        print('response: $response');
        final String accessToken = responseData['access_token'] ?? '';
        final String refreshToken = responseData['refresh_token'] ?? '';
        print('registrationapi access token $accessToken, refresh_token: $refreshToken');
        tokenApiKeeper.setRefreshToken(refreshToken); // Store the refresh token
        tokenApiKeeper.setAccessToken(accessToken); // Store the refresh token
        tokenApiKeeper.registerLogin();
        return response.toString(); // Successful registration
      } else {
        return 'Backend request failed with status code ${response.statusCode}';
      }
    } catch (error) {
      return 'Please try again later.$error';
      //return 'Dio error: $error';
    }
  }
}