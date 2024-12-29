// Filename: posts_display_query.dart
import 'package:flutter/material.dart';
import '../../api/api_feed_audio_image_service.dart';
import '../../api/api_like_post.dart';
import '../../models/post.dart';
import '../../widgets/post_card.dart';
import 'full_screen_post_view.dart';

class PostsAudioImageDisplayScreen extends StatefulWidget {
  final bool autoplayEnabled;
  final String? userId;
  final List<String>? tags;
  final String? category;
  final String? characteristics;
  final bool showLikedPostsOnly; // New parameter to control mode

  PostsAudioImageDisplayScreen({
    Key? key,
    required this.autoplayEnabled,
    this.userId,
    this.tags,
    this.category,
    this.characteristics,
    this.showLikedPostsOnly = false, // Default to false to preserve existing functionality
  }) : super(key: key);

  @override
  _PostsAudioImageDisplayScreenState createState() => _PostsAudioImageDisplayScreenState();
}

class _PostsAudioImageDisplayScreenState extends State<PostsAudioImageDisplayScreen> {
  late List<Post> posts;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    print('_fetchPosts username: ${widget.userId}');
    ApiFeedAudioImageService apiFeedAudioImageService = ApiFeedAudioImageService();
    ApiLikePost apiLikePost = ApiLikePost();

    if (widget.showLikedPostsOnly && widget.userId != null) {
      // Fetch liked posts if requested and userId is provided
      posts = await apiLikePost.getLikedPosts(widget.userId!);
    } else {
      // Fetch general posts based on other filters
      posts = await apiFeedAudioImageService.fetchPosts(
        userId: widget.userId,
        tags: widget.tags,
        category: widget.category,
        characteristics: widget.characteristics,
      );
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? Center(child: Text('No posts available', style: TextStyle(color: Colors.white)))
          : RefreshIndicator(
        onRefresh: _fetchPosts,
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FullScreenPostView(
                      posts: posts,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: PostCard(post: posts[index], autoplayEnabled: widget.autoplayEnabled),
            );
          },
        ),
      ),
    );
  }
}
