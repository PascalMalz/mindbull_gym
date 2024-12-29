//todo why is it called two times

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:self_code/api/token_handler.dart';

Dio dio = Dio();

Future<Map<String, dynamic>> fetchUserProfile(String accessToken) async {
  final TokenHandler tokenApiKeeper = GetIt.instance.get<TokenHandler>();
  //accessToken = await tokenApiKeeper.getRefreshToken();
  print('fetchUserProfile accessToken: $accessToken');
  try {
    print('fetchUserProfile: user data loading');
    print('fetchUserProfile: AccessToken: $accessToken');
    final response = await dio.get(
      'https://neurotune.de/sum/api/user-profile/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    print('fetchUserProfile: Response data: $response');
    if (response.statusCode == 200) {
      print('fetchUserProfile Response data: $response.data');
      return response.data;
    } else {
      throw Exception('fetchUserProfile: Failed to load user profile');
    }
  } catch (e) {
    // Handle Dio errors, e.g., DioError.
    throw Exception('fetchUserProfile: Failed to load user profile: $e');
  }
}

Future<Map<String, dynamic>> fetchOtherUserProfile(String accessToken, String userId) async {
  // Adapt the URL or request parameters as necessary
  print('fetchOtherUserProfile accessToken: $accessToken');
  try {
    print('fetchOtherUserProfile: other user data loading');
    print('fetchOtherUserProfile: AccessToken: $accessToken');
    print('fetchOtherUserProfile: userId: $userId');
    final response = await dio.get(
      'https://neurotune.de/sum/api/user-profile/$userId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    print('fetchOtherUserProfile: Response data: $response');
    if (response.statusCode == 200) {
      //print('Response data: $response.data');
      return response.data;
    } else {
      throw Exception('fetchOtherUserProfile: Failed to load user profile');
    }
  } catch (e) {
    // Handle Dio errors, e.g., DioError.
    throw Exception('fetchOtherUserProfile: Failed to load user profile: $e');
  }
  // Handle the response similarly to fetchUserProfile
}
