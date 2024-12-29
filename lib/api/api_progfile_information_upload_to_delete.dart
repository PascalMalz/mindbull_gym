import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:self_code/api/token_handler.dart';
import '../main.dart';

class ApiProfileInformationUpload {
  final Dio _dio = Dio();
  final TokenHandler tokenApiKeeper = getIt<TokenHandler>(); // Use getIt to get the instance

  Future<String?> uploadProfilePicture(File imageFile) async {
    final String authToken = await tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/sum/api/upload-profile-picture/';

    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data', // Change Content-Type
      'Authorization': 'Bearer $authToken',
      // Add any other headers like Authorization if necessary
    };

    try {
      FormData formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'upload.jpg',
        ),
      });

      final Response response = await _dio.post(
        apiUrl,
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return null; // Image uploaded successfully
      } else if (response.statusCode == 400) {
        return 'No image file provided';
      } else if (response.statusCode == 401) {
        return 'Unauthorized'; // Handle unauthorized access if needed
      } else {
        return 'Backend request failed with status code ${response.statusCode}';
      }
    } catch (error) {
      return 'Please try again later.';
      // Uncomment the next line to get more detailed error info during development:
      // return 'Dio error: $error';
    }
  }

  Future<String?> updateBio(String newBio) async {
    final String authToken = await tokenApiKeeper.getAccessToken();
    final String apiUrl = 'https://neurotune.de/sum/api/update-bio/';

    final Map<String, String> headers = {
      'Content-Type': 'application/json', // Change Content-Type
      'Authorization': 'Bearer $authToken',
      // Add any other headers like Authorization if necessary
    };

    try {
      final Map<String, String> data = {
        'bio': newBio,
      };

      final Response response = await _dio.post(
        apiUrl,
        data: jsonEncode(data),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return null; // Bio updated successfully
      } else if (response.statusCode == 400) {
        return 'Bio update failed';
      } else if (response.statusCode == 401) {
        return 'Unauthorized'; // Handle unauthorized access if needed
      } else {
        return 'Backend request failed with status code ${response.statusCode}';
      }
    } catch (error) {
      return 'Please try again later.';
      // Uncomment the next line to get more detailed error info during development:
      // return 'Dio error: $error';
    }
  }
}
