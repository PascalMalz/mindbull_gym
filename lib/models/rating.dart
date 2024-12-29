class Rating {
  String? userId;
  String? postId;
  int? rating;

  Rating({this.userId, this.postId, this.rating});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      userId: json['user'],
      postId: json['post'],
      rating: json['rating'],
    );
  }
}
