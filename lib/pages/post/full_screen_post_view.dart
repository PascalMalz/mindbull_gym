// Filename: full_screen_post_view.dart
//todo what to do when a user clicks on a video it first of all gets played but and not stopped / resumed in full screen. Also the click on video is not opening full screen.
//todo autoplay / stop when relling from one page to the next
import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../widgets/post_card.dart';

class FullScreenPostView extends StatelessWidget {
  final List<Post> posts;
  final int initialIndex;

  const FullScreenPostView({
    Key? key,
    required this.posts,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Reel Full Screen'), // Title text
        actions: [
          IconButton(
            padding: EdgeInsets.all(0.0),
            icon: Icon(Icons.more_vert, color: Colors.white, size: 30,),
            onPressed: () {
              // TODO: Handle the Report action
            },
          ),],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Navigate back when pressed
        ),
        backgroundColor: Colors.black, // Optional: AppBar background color
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Optional: Title text style
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) => PostCard(post: posts[index]),
      ),
    );
  }
}
