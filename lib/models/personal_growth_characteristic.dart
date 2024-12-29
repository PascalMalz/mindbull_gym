import 'characteristic_rating.dart';

class PersonalGrowthCharacteristic {
  String? category;
  String? name;
  String? description;
  CharacteristicRating rating;

  PersonalGrowthCharacteristic({
    this.category = '',  // Default to empty string if not provided
    this.name = '',  // Default to empty string if not provided
    this.description = '',  // Default to empty string if not provided
    required this.rating,
  });

  factory PersonalGrowthCharacteristic.fromJson(Map<String, dynamic> json) {
    return PersonalGrowthCharacteristic(
      category: json['category'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      rating: CharacteristicRating(0),  // Default rating, adjust as necessary
    );
  }
}
