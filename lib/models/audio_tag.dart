class AudioTag {
  String? audioId;
  String? tagId;
  DateTime? createdAt;

  AudioTag({this.audioId, this.tagId, this.createdAt});

  factory AudioTag.fromJson(Map<String, dynamic> json) {
    return AudioTag(
      audioId: json['audio'],
      tagId: json['tag'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}
