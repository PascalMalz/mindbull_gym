class ContentTag {
  String? tagId;
  String? contentTypeId;
  int? objectId;
  DateTime? createdAt;

  ContentTag({this.tagId, this.contentTypeId, this.objectId, this.createdAt});

  factory ContentTag.fromJson(Map<String, dynamic> json) {
    return ContentTag(
      tagId: json['tag'],
      contentTypeId: json['content_type'],
      objectId: json['object_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}
