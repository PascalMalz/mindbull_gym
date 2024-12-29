class Comment {
  final String commentId;
  String? userId;
  String? postId;
  String description;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? userName; // Add this line to include the username

  Comment({
    required this.commentId,
    this.userId,
    this.postId,
    required this.description,
    this.createdAt,
    this.updatedAt,
    this.userName, // Add this line to the constructor
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['id'].toString(), // Convert integer to string
      userId: json['user'], // Assuming 'user' is already a string (UUID)
      postId: json['post'].toString(), // Convert integer to string
      description: json['description'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      userName: json['userName'], // Assuming 'userName' is already a string
    );
  }

}
