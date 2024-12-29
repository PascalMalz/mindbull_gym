
import 'package:dio/dio.dart';
import '../models/composition.dart'; // Assuming you have a Composition model

class ApiCompositionGet {
  static final Dio dio = Dio();

  static Future<Composition?> fetchComposition(String compositionId) async {
    try {
      var response = await dio.get('https://neurotune.de/api/compositions/$compositionId/');
      print('ApiCompositionGet: loading compositions from backend');
      print(response);
      if (response.statusCode == 200) {
        return Composition.fromJson(response.data as Map<String, dynamic>);
      } else {
        print('Failed to load composition with status code: ${response.statusCode}');
        return null; // Now it's valid to return null.
      }
    } catch (e) {
      print('Error fetching composition: $e');
      return null; // Returning null in case of exception
    }
  }
}