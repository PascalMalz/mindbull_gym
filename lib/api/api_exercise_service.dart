// Filename: api_exercise_service.dart

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/exercise.dart';
import '../api/token_handler.dart';
import '../main.dart';

class ApiExerciseService {
  static final Dio dio = Dio();
  final TokenHandler tokenApiKeeper = getIt<TokenHandler>();

  Future<List<Exercise>> fetchExercises({
    required String exerciseType,
  }) async {
    try {
      final String accessToken = await tokenApiKeeper.getAccessToken();
      String baseUrl = 'https://neurotune.de/api/exercises/';
      Map<String, dynamic> queryParameters = {
        'exercise_type': exerciseType,
        'ordering':
            'duration', // Query to order exercises by duration ascending
      };

      print(
          'ApiExerciseService fetchExercises queryParameters $queryParameters');

      // Include the Authorization header with the accessToken
      var response = await dio.get(
        baseUrl,
        queryParameters: queryParameters,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      print("Raw response data: ${response.data}");

      // Save the response data to a file for debugging
      Directory docDir = await getApplicationDocumentsDirectory();
      String path = '${docDir.path}/response_exercises.txt';
      File file = File(path);
      await file.writeAsString(response.data.toString(), mode: FileMode.write);

      if (response.statusCode == 200) {
        var responseData = response.data;

        if (responseData is List) {
          return responseData.map((data) {
            return Exercise.fromJson(data as Map<String, dynamic>);
          }).toList();
        } else {
          print("Error: Response data is not a List");
          return [];
        }
      } else {
        throw Exception(
            'Failed to load exercises with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exercises: $e');
      return [];
    }
  }
}
