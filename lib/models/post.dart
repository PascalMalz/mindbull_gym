import 'package:self_code/models/tag.dart';

class Post {
  String? postId; // Assuming you're using the user's ID
  String? userId; // Assuming you're using the user's ID
  String? username; // Add a field for the username
  String? profilePictureUrl;
  bool? isLikedByUser;
  int? totalLikes;
  String? content;
  double? ratingAverage; // This field doesn't seem to be in the response
  String? audioId; // This field is named 'audio' in the response and can be null
  String? audioLink; // This field is named 'audio' in the response and can be null
  String? videoLink; // New field for the video link
  String? imageUrl;
  String? compositionId; // Assuming you're using the composition's ID
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Tag>? tags;

  Post({
    this.postId,
    this.userId,
    this.username,
    this.profilePictureUrl,
    this.isLikedByUser,
    this.totalLikes,
    this.content,
    this.ratingAverage,
    this.audioId,
    this.audioLink,
    this.videoLink,
    this.imageUrl,
    this.compositionId,
    this.createdAt,
    this.updatedAt,
    this.tags,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String? imageUrl;

    print('Post json[image_set] ${json['image_set']}');

    if (json['image_set'] != null && json['image_set'].isNotEmpty) {
      var imageSet = json['image_set'] as List<dynamic>;
      if (imageSet.isNotEmpty) {
        var firstImage = imageSet.first as Map<String, dynamic>;
        var imageDetails = firstImage['image'] as Map<String, dynamic>?;
        if (imageDetails != null && imageDetails.containsKey('image_url')) {
          imageUrl = imageDetails['image_url'] as String?;
        }
      }
    }

    String? videoLink;
    // Add logic to extract video link from JSON response if it's available
    if (json['video_fk'] != null) {
      // Directly accessing 'video_file' within 'video_fk'
      videoLink = json['video_fk']['video_file'] as String?;
    }
/*  print('Post json: $json');
    String? userId;
    print('json[user]: ${json['user']}');
    // Check if 'user' is directly a string ID
    if (json['user'] is String) {
      userId = json['user'] as String;
    }
    // Fallback to check for a nested 'id' if 'user' is a map/object
    else if (json['user'] is Map<String, dynamic> && json['user']['id'] != null) {
      userId = json['user']['id'] as String?;
    }*/

    // Print statements for debugging (optional)
    print('Post imageUrl: $imageUrl');
    print('Post videoLink: $videoLink');

    print('Post imageUrl $imageUrl');
    return Post(
      postId: json['post_uuid'] as String?,
      userId: json['user_id_backend_post'] != null ? json['user_id_backend_post']['id'] as String? : null,
      username: json['user_id_backend_post'] != null ? json['user_id_backend_post']['username'] as String? : null,
      profilePictureUrl: json['user_id_backend_post'] != null ? json['user_id_backend_post']['profile_picture'] as String? : null,
      totalLikes: json['total_likes'] as int?,
      content: json['post_description'] as String?,
      audioLink: json['audio_link'] != null ? (json['audio']['audio_link'] as String?) : null,
      videoLink: videoLink,
      // No ratingAverage field in the response
      // If 'id' field of 'audio' is an integer, handle it appropriately
      audioId: json['audio_file'] != null ? (json['audio']['id'] as int?)?.toString() : null,
      imageUrl: imageUrl,
      compositionId: json['composition_fk'] != null ? json['composition_fk']['composition_uuid'] as String  : null,
      // Handle other integer fields similarly
      createdAt: json.containsKey('created_at') ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json.containsKey('updated_at') ? DateTime.tryParse(json['updated_at']) : null,
      tags: json['tags'] != null ? List.from(json['tags']).map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList() : [],
    );
  }

  @override
  String toString() {
    return 'Post{'
        'postId: $postId, '
        'userId: $userId, '
        'profilePictureUrl: $profilePictureUrl, '
        'username: $username, '
        'totalLikes: $totalLikes, '
        'content: $content, '
        'ratingAverage: $ratingAverage, '
        'audioId: $audioId, '
        'audioLink: $audioLink, '
        'videoLink: $videoLink, '
        'imageUrl: $imageUrl, '
        'compositionId: $compositionId, '
        'createdAt: ${createdAt?.toIso8601String()}, '
        'updatedAt: ${updatedAt?.toIso8601String()}, '
        'tags: ${tags?.map((tag) => tag.toString()).toList()}';
  }
}
