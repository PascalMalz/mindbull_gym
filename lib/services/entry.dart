class Entry {
  String name;
  List<Rating> ratings;

  Entry(this.name, this.ratings);

  // Convert Entry object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
    };
  }

  // Create Entry object from JSON
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      json['name'],
      (json['ratings'] as List<dynamic>)
          .map((ratingJson) => Rating.fromJson(ratingJson))
          .toList(),
    );
  }
}

class Rating {
  int value;

  Rating(this.value);

  // Convert Rating object to JSON
  Map<String, dynamic> toJson() {
    return {'value': value};
  }

  // Create Rating object from JSON
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(json['value']);
  }
}
