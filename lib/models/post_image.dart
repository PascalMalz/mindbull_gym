class PostImage {
  String? postId;
  String? imageId;

  PostImage({this.postId, this.imageId});

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      postId: json['post'],
      imageId: json['image'],
    );
  }
}
