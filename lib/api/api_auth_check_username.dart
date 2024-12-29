import 'package:dio/dio.dart';

class ApiAuthCheckUsernameAvailability {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://neurotune.de/sum/api',
    // Add this to allow 409 as a valid response
    validateStatus: (status) {
      return status! >= 200 && status < 500;
    },
  ));

  Future<String> checkUsernameAvailability(String username) async {
    try {
      final response = await _dio.post(
        '/check-username/',
        data: {'username': username},
      );

      if (response.statusCode == 200) {
        // Username is available
        return 'Username available';
      } else if (response.statusCode == 409) {
        // Username is not available
        return 'Username already in use, please try another one.';
      }
      else {
        return 'Error in request. Please try again later.';
      }
    } on DioException catch (e) {
      // Handle error, e.g., network issues
      print('Error checking username availability: $e');
      return 'There was an error in the request. Please start over or try later.';
    }
  }

}
