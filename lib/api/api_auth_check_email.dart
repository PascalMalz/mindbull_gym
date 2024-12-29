import 'package:dio/dio.dart';

class ApiAuthCheckEmail {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://neurotune.de/sum/api',
    // Add this to allow 409 as a valid response
    validateStatus: (status) {
      return status! >= 200 && status < 500;
    },
  ));

  Future<String> checkEmailAvailability(String email) async {
    try {
      final response = await _dio.post(
        '/check-email/', // Replace with your actual API endpoint for checking email
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        // Email is available
        return 'Email available';
      } else if (response.statusCode == 409) {
        // Email is not available
        return 'Email already registered, please try another one.';
      } else {
        return 'Error in request. Please try again later.';
      }
    } on DioException catch (e) {
      // Handle error, e.g., network issues
      print('Error checking email availability: $e');
      return 'There was an error in the request. Please start over or try later.';
    }
  }
}
