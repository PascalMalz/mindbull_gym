class TagRating {
  String? tagId;
  int? contentId;
  String? contentType;
  String? userId;
  int? rating;
  DateTime? createdAt;
  DateTime? updatedAt;

  TagRating({this.tagId, this.contentId, this.contentType, this.userId, this.rating, this.createdAt, this.updatedAt});

  factory TagRating.fromJson(Map<String, dynamic> json) {
    return TagRating(
      tagId: json['tag'],
      contentId: json['content_id'],
      contentType: json['content_type'],
      userId: json['user'],
      rating: json['rating'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
    );
  }
}
