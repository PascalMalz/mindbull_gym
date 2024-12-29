import 'package:uuid/uuid.dart';

class CompositionTag {
  final String id;
  final String tag;
  final DateTime createdAt;

  CompositionTag({
    String? id, // id is now an optional parameter
    required this.tag,
    required this.createdAt,
  }) : id = id ?? const Uuid().v4();

  factory CompositionTag.fromJson(Map<String, dynamic> json) {
    return CompositionTag(
      id: json['id'],
      tag: json['tag'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag': tag,
      'created_at': createdAt.toIso8601String(),
    };
  }
}