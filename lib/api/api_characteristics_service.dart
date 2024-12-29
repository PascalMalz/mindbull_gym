// Filename: api_characteristics_service.dart
import 'package:dio/dio.dart';
import '../models/personal_growth_characteristic.dart';

class ApiCharacteristicsService {
  static final Dio dio = Dio();

  static Future<Map<String, List<PersonalGrowthCharacteristic>>> fetchCharacteristics() async {
    try {
      var response = await dio.get('https://neurotune.de/api/personal_growth_characteristics/');
      if (response.statusCode == 200) {
        var data = response.data as List;
        Map<String, List<PersonalGrowthCharacteristic>> categorizedEntries = {};
        for (var characteristicJson in data) {
          PersonalGrowthCharacteristic characteristic = PersonalGrowthCharacteristic.fromJson(characteristicJson);
          // Ensure category is non-null by providing a default value
          String categoryKey = characteristic.category ?? 'Uncategorized';
          categorizedEntries.putIfAbsent(categoryKey, () => []).add(characteristic);
        }
        return categorizedEntries;
      } else {
        throw Exception('Failed to load characteristics with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching characteristics: $e');
      return {};
    }
  }
}

