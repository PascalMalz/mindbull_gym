import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:self_code/models/personal_growth_characteristic.dart';

import '../api/api_characteristics_service.dart'; // adjust import as necessary

class CharacteristicsProvider with ChangeNotifier {
  final Box _characteristicsBox = Hive.box('characteristicsRatingsBox');

  Map<String, List<PersonalGrowthCharacteristic>> _categorizedEntries = {};

  CharacteristicsProvider() {
    initializeData();
  }

  Future<void> initializeData() async {
    // First, load data from Hive
    await _loadDataFromHive();

    // Then, fetch and update data from the API
    await fetchAndUpdateCharacteristics();
  }


  // Getter to access categorized entries
  Map<String, List<PersonalGrowthCharacteristic>> get categorizedEntries => _categorizedEntries;


  Future<void> _loadDataFromHive() async {
    // Load characteristics and ratings from Hive
    var characteristics = _characteristicsBox.values.cast<PersonalGrowthCharacteristic>().toList();
    print('characteristics from Hive: $characteristics');
    // Process and categorize the data
    _categorizedEntries = _categorizeCharacteristics(characteristics);

    notifyListeners();
  }

  // Utility method to categorize characteristics
  Map<String, List<PersonalGrowthCharacteristic>> _categorizeCharacteristics(
      List<PersonalGrowthCharacteristic> characteristics) {
    Map<String, List<PersonalGrowthCharacteristic>> categorized = {};
    for (var characteristic in characteristics) {
      String category = characteristic.category ?? 'Uncategorized';
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(characteristic);
    }
    return categorized;
  }
  // Fetch and update characteristics
  Future<void> fetchAndUpdateCharacteristics() async {
    try {
      var fetchedCharacteristics = await ApiCharacteristicsService.fetchCharacteristics();
      print('Fetched characteristics: $fetchedCharacteristics');

      // Load existing ratings from Hive
      var existingCharacteristics = _characteristicsBox.values.cast<PersonalGrowthCharacteristic>().toList();
      var existingRatingsMap = { for (var c in existingCharacteristics) c.name: c.rating };

      // Initialize a new map for merged and filtered characteristics
      Map<String, List<PersonalGrowthCharacteristic>> newCategorizedEntries = {};

      // Merge fetched characteristics with existing ratings, or add them anew
      for (var category in fetchedCharacteristics.keys) {
        for (var characteristic in fetchedCharacteristics[category]!) {
          // Apply existing rating if available, otherwise add new characteristic
          if (existingRatingsMap.containsKey(characteristic.name)) {
            characteristic.rating = existingRatingsMap[characteristic.name]!;
          }
          newCategorizedEntries.putIfAbsent(category, () => []).add(characteristic);
        }
      }

      // Replace the old categorized entries with the new merged and filtered list
      _categorizedEntries = newCategorizedEntries;

      // Update Hive with the new merged and filtered data
      // This ensures all fetched characteristics are stored, regardless of prior existence
      for (var category in _categorizedEntries.keys) {
        for (var characteristic in _categorizedEntries[category]!) {
          _characteristicsBox.put(characteristic.name, characteristic);
        }
      }

      notifyListeners(); // Notify widgets to rebuild
    } catch (e) {
      print('Error fetching and updating characteristics: $e');
    }
  }




  // Update rating for a specific characteristic
  void updateRating(String category, PersonalGrowthCharacteristic characteristic, int newRating) {
    print('try to called UpdateRating');
    // Update the rating of the characteristic
    characteristic.rating.value = newRating;

    // Save the updated characteristic back to Hive
    _characteristicsBox.put(characteristic.name, characteristic);

    // Update the characteristic in the categorizedEntries
    List<PersonalGrowthCharacteristic> categoryList = _categorizedEntries[category] ?? [];
    int indexToUpdate = categoryList.indexWhere((c) => c.name == characteristic.name);
    if (indexToUpdate != -1) {
      categoryList[indexToUpdate] = characteristic;
      print('indexToUpdate != -1');
    } else {
      print('indexToUpdate = -1');
      // Handle the case where the characteristic might not exist (e.g., if new or removed from backend)
      categoryList.add(characteristic);
      _categorizedEntries[category] = categoryList;  // Update the category list
    }
    print('rating entry stored in Hive, name: ${characteristic.name}, characteristic.rating.value: ${characteristic.rating.value}');
    // Notify all listeners to rebuild the UI with updated data
    notifyListeners();
  }
}
