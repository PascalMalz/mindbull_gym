class ImageModel {
  String? userId;
  String? imageFile;
  DateTime? createdAt;

  ImageModel({this.userId, this.imageFile, this.createdAt});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      userId: json['user'],
      imageFile: json['image_file'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}
