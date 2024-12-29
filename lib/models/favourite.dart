class Favorite {
  String? userId;
  String? postId;
  DateTime? createdAt;

  Favorite({this.userId, this.postId, this.createdAt});

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      userId: json['user'],
      postId: json['post'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}
