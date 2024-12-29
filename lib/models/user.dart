class User {
  final String email;
  final String? id; // Add userid field
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? age;
  final String? profilePictureUrl;
  final String? bio;
  bool? isFollowedByUser;
  int? followersCount;
  int? followingCount;

  User({
    required this.email,
    this.id, // Add userid parameter to the constructor
    this.username,
    this.firstName,
    this.lastName,
    this.age,
    this.profilePictureUrl,
    this.bio,
    this.isFollowedByUser,
    this.followersCount,
    this.followingCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      id: json['userid'], // Initialize userid from JSON
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      profilePictureUrl: json['profile_picture_url'],
      bio: json['bio'],
      followersCount: json['followers_count'] as int?,
      followingCount: json['following_count'] as int?,
    );
  }

  // Improve prints to console:
  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, profilePictureUrl: $profilePictureUrl, bio: $bio, followersCount: $followersCount, followingCount: $followingCount,)';
  }
}
