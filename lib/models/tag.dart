class Tag {
  String? tagName;

  Tag({this.tagName});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tagName: json['tag_name'],
    );
  }
}
