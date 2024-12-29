class PostTag {
  String? postId;
  String? tagId;
  DateTime? createdAt;

  PostTag({this.postId, this.tagId, this.createdAt});

  factory PostTag.fromJson(Map<String, dynamic> json) {
    return PostTag(
      postId: json['post'],
      tagId: json['tag'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}
