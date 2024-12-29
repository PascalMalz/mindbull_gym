import 'package:dio/dio.dart';
import 'package:self_code/api/token_handler.dart';
import '../main.dart';

class ApiFollowUser {
  final Dio _dio = Dio();
  final TokenHandler _tokenApiKeeper = getIt<TokenHandler>();

  Future<void> followUser(String userId) async {
    final String authToken = await _tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/sum/api/user/$userId/follow/';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
    };

    try {
      final Response response = await _dio.post(
        apiUrl,
        options: Options(headers: headers),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        // Assuming a 204 No Content response for a successful follow
        print("User followed successfully");
      } else {
        // Handle other statuses appropriately
        print("Failed to follow the user. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle any errors that occur during the request
      print("Failed to follow the user: $error");
    }
  }

  Future<bool> checkFollowStatus(String userId) async {
    final String authToken = await _tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/sum/api/user/$userId/check_follow/';
    print('Follow Check');
    final Response response = await _dio.get(
      apiUrl,
      options: Options(
        headers: {'Authorization': 'Bearer $authToken'},
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      print('response.data: $data');
      return data['is_following'];
    } else {
      throw Exception('Failed to check follow status');
    }
  }

  Future<List<dynamic>> fetchFollowersList(String userId) async {
    final String authToken = await _tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/sum/api/user/$userId/followers_list/';
    try {
      final Response response = await _dio.get(apiUrl, options: Options(headers: {'Authorization': 'Bearer $authToken'}));
      if (response.statusCode == 200) {
        print("fetchFollowersList seems to be loaded correctly");
        print('Follower List: $response');
        return response.data as List;
      } else {
        throw Exception('Failed to fetch followers list. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch followers list: $error');
    }
  }

  Future<List<dynamic>> fetchIFollowList(String userId) async {
    final String authToken = await _tokenApiKeeper.getAccessToken();
      final String apiUrl = 'https://neurotune.de/sum/api/user/$userId/i_follow_list/';
    try {
      final Response response = await _dio.get(apiUrl, options: Options(headers: {'Authorization': 'Bearer $authToken'}));
      if (response.statusCode == 200) {
        print('I follow List: $response');
        return response.data as List;
      } else {
        throw Exception('Failed to fetch following list. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch following list: $error');
    }
  }

}
