import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:self_code/api/api_comment_get.dart';
import 'package:self_code/api/api_like_post.dart';
import 'package:self_code/widgets/seek_new_try/audio_player_composition_widget.dart';
import 'package:self_code/widgets/seek_new_try/audio_player_single_audio_widget.dart';
import 'package:self_code/widgets/video_player_widget.dart';
import 'package:video_player/video_player.dart';
import '../api/api_composition_get.dart';
import '../api/api_post_comment.dart';
import '../main.dart';
import '../models/audio.dart';
import '../models/composition.dart';
import '../models/composition_audio.dart';
import '../models/post.dart';
import '../models/tag.dart';
import '../pages/profile.dart';
import '../provider/user_data_provider.dart';
import '../services/MediaPlayer.dart';
import 'composition_tree_widget.dart';
import '../models/comment.dart';

class PostCard extends StatefulWidget {
  late Post? post;
  final bool autoplayEnabled;
  //Preview fields
  final Audio? previewAudio;
  final ImageProvider? previewImage;

  PostCard({
    Key? key,
    this.post,
    this.autoplayEnabled = false,
    //Preview fields
    this.previewAudio,
    this.previewImage,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Composition? compositionToPlay;
  Audio? audioFileToPlay;
  bool toggle_composition_tree = false;
  @override
  void initState() {
    super.initState();
    var post = widget.post;
    print('PostCard composition id: ${post?.compositionId}');
    if (widget.previewAudio != null) {
      _loadUserData();
      audioFileToPlay = widget.previewAudio;
    } else if (post?.compositionId != null) {
      // Load composition if ID is available
      loadComposition(post!.compositionId!);
    } else if (post?.audioLink != null) {
      // Load audio file if link is available
      audioFileToPlay = Audio(
          clientAppAudioFilePath: post?.audioLink!,
          title: ''); // Assume other required fields are filled as needed
    }
    _checkLikeStatus();
  }

  void _loadUserData() {
    var userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    // Assuming userDataProvider provides a method to fetch user details
    widget.post?.profilePictureUrl =
        userDataProvider.currentUser?.profilePictureUrl;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post != oldWidget.post) {
      // If the post object has changed, you might need to re-check the like status.
      // This depends on how your data is structured and if these values are expected to change.
      _checkLikeStatus();
    }
  }

  //Function to check if the current user has already liked that post
  void _checkLikeStatus() async {
    ApiLikePost apiLikePost = getIt<ApiLikePost>();
    bool isLiked =
        await apiLikePost.checkLikeStatus(widget.post!.postId.toString());
    setState(() {
      widget.post?.isLikedByUser = isLiked;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadComposition(String compositionId) async {
    print('PostCard: loadComposition');
    Composition? loadedComposition =
        await ApiCompositionGet.fetchComposition(compositionId);
    if (loadedComposition != null) {
      setState(() {
        compositionToPlay = loadedComposition;
      });
    }
    // Handle case when composition is null (e.g., display error or placeholder)
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    print('imageUrl: ${post?.imageUrl}');
    Widget playerWidget = SizedBox.shrink();
    Widget compositionTreeWidget = SizedBox.shrink();
    Widget videoPlayerWidget = SizedBox.shrink();
    // Determine if there's a video link
    bool hasVideoLink = post?.videoLink != null;

    if (hasVideoLink) {
      print('videoLink in post: ${post?.videoLink}');
      videoPlayerWidget = VideoPlayerWidget(videoUrl: post?.videoLink);
    } else if (compositionToPlay != null) {
      // Display composition player widget
      if (toggle_composition_tree) {
        compositionTreeWidget = SingleChildScrollView(
          // Vertical scroll
          child: SingleChildScrollView(
            // Horizontal scroll (if needed)
            scrollDirection: Axis.horizontal,
            child: CompositionTreeView(composition: compositionToPlay!),
          ),
        );
        playerWidget = SizedBox.shrink();
      } else {
        compositionTreeWidget = SizedBox.shrink();
        playerWidget = AudioPlayerCompositionWidget(
          composition: compositionToPlay!,
          autoplayEnabled: widget.autoplayEnabled,
        );
      }
    } else if (audioFileToPlay != null) {
      // Display single audio player widget
      playerWidget = AudioPlayerSingleAudioWidget(
        audioFile: audioFileToPlay!,
        autoplayEnabled: widget.autoplayEnabled,
      );
      compositionTreeWidget = SizedBox.shrink();
    } else {
      // No audio content available or still loading
      playerWidget = CircularProgressIndicator(); // Or some other placeholder
      compositionTreeWidget = SizedBox.shrink();
    }

    // Default image provider
    final ImageProvider<Object> defaultImageProvider =
        AssetImage('assets/background_sky.jpg');

    Widget? imageWidget;

    if (widget.previewImage != null) {
      imageWidget = Image(image: widget.previewImage!, fit: BoxFit.cover);
    } else if (post?.imageUrl != null && post!.imageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        post!.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          // If the network image fails to load, fallback to the default image
          return Image.asset('assets/background_sky.jpg', fit: BoxFit.cover);
        },
      );
    } else if (hasVideoLink) {
      imageWidget = null;
    } else {
      imageWidget = Image.asset('assets/background_sky.jpg', fit: BoxFit.cover);
    }

/*      if (widget.previewImage != null) {
        imageWidget = Image(image: widget.previewImage,fit: BoxFit.cover,);
      } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
        imageWidget = Image.network(widget.imageUrl!);
      } else {
        imageWidget = Image.asset('assets/background_sky.jpg',fit: BoxFit.contain,);
      }*/
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
      child: Container(
        height: 550,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              top: 100,
              left: 40,
              right: 40,
              bottom: 40,
              child: Opacity(opacity: 0.2, child: imageWidget),
            ),

            if (!hasVideoLink)
              Positioned(
                bottom: 40,
                left: 40,
                right: 40, // Added right constraint to bound the width
                top: 100, // Added top constraint to bound the height
                child: Container(
                  child: toggle_composition_tree
                      ? compositionTreeWidget // Display this when toggle_composition_tree is true
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            playerWidget, // Display this when toggle_composition_tree is false
                            // If you have other widgets that should be displayed along with playerWidget, include them here.
                          ],
                        ),
                ),
              ),
            if (hasVideoLink)
              Align(
                alignment: Alignment.center,
                child: videoPlayerWidget,
              ),
// Assuming this widget is part of a stateful widget or stateless widget class

            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 5),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      print('userId: post?.userId: ${post?.userId}');
                      // Navigate to the profile page with the userId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(userId: post?.userId)),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: post!.profilePictureUrl != null &&
                              post.profilePictureUrl!.isNotEmpty
                          ? NetworkImage(post.profilePictureUrl!)
                          : AssetImage('assets/default_profile_picture.png')
                              as ImageProvider,
                    ),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the profile page with the userId
                      print('userId: post?.userId: ${post?.userId}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(userId: post?.userId)),
                      );
                    },
                    child: Text(
                      post?.username ?? 'Username could not be loaded',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 35), // Adjusted according to your layout
                ],
              ),
            ),

            Positioned(
              top: 60,
              left: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post?.content ?? '',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Text(
                    textAlign: TextAlign.center,
                    "Posted at: ${formatDateString(post?.createdAt)}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            //todo I want arrows to show full screen...
            Positioned(
              top: 10,
              right: 180, // To position it on the right side
              child: Opacity(
                opacity: 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        //color: Colors.white, // Set your desired background color here
                        shape: BoxShape.circle, // Makes the container round
/*                            boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5), // Adjust the color and opacity for the glow effect
                              spreadRadius: 3, // Increases the size of the shadow
                              blurRadius: 7, // Softens the shadow
                              offset: Offset(0, 0), // Changes position of shadow
                            ),
                          ],*/
                      ),
                      padding: EdgeInsets.all(
                          8.0), // Adjust the padding to fit your design
                      child: Icon(
                        Icons
                            .fullscreen_rounded, // Toggles between play icon and account tree icon
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    Text('' ?? '',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            if (!hasVideoLink)
              Positioned(
                top: 10,
                right: 30, // To position it on the right side
                child: Opacity(
                  opacity: 0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            toggle_composition_tree = !toggle_composition_tree;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Set your desired background color here
                            shape: BoxShape.circle, // Makes the container round
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(
                                    0.5), // Adjust the color and opacity for the glow effect
                                spreadRadius:
                                    3, // Increases the size of the shadow
                                blurRadius: 7, // Softens the shadow
                                offset:
                                    Offset(0, 0), // Changes position of shadow
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(
                              8.0), // Adjust the padding to fit your design
                          child: Icon(
                            toggle_composition_tree
                                ? Icons.play_arrow
                                : Icons
                                    .account_tree, // Toggles between play icon and account tree icon
                            color: Colors.deepPurple,
                            size: 40,
                          ),
                        ),
                      ),
                      Text('' ?? '',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),

            Positioned(
              bottom: 20,
              right: -15, // To position it on the right side
              child: Opacity(
                opacity: 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    IconButton(
                      padding: EdgeInsets.all(0.0),
                      icon: Icon(
                        Icons.star_rate_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        // TODO: Handle the Save action
                      },
                    ),
                    Text(post?.ratingAverage.toString() ?? '',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                    SizedBox(
                      height: 8,
                      width: 80,
                    ),
                    IconButton(
                      padding: EdgeInsets.all(0.0),
                      icon: Icon(
                        // Use the null-coalescing operator to ensure a non-nullable condition
                        widget.post?.isLikedByUser ?? false
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () async {
                        if (widget.post != null) {
                          ApiLikePost apiLikePost = getIt<ApiLikePost>();
                          try {
                            await apiLikePost
                                .likePost(widget.post!.postId.toString());
                            // Toggle the isLikedByUser state and update the like count accordingly
                            setState(() {
                              widget.post!.isLikedByUser =
                                  !(widget.post!.isLikedByUser ?? false);
                              if (widget.post!.isLikedByUser ?? false) {
                                widget.post!.totalLikes =
                                    (widget.post!.totalLikes ?? 0) + 1;
                              } else {
                                widget.post!.totalLikes =
                                    (widget.post!.totalLikes ?? 0) - 1;
                              }
                            });
                            print("Like status toggled successfully.");
                          } catch (error) {
                            // Handle or display the error
                            print("Error toggling like status: $error");
                          }
                        }
                      },
                    ),
                    Text(
                      '${widget.post?.totalLikes ?? 0} likes',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    IconButton(
                      padding: EdgeInsets.all(0.0),
                      icon: Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        // TODO: Handle the Share action
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    IconButton(
                      padding: EdgeInsets.all(0.0),
                      icon: Icon(
                        Icons.note_add,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        // TODO: Handle the Use as Template action
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    IconButton(
                      padding: EdgeInsets.all(0.0),
                      icon: Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        showCommentsDialog(context, post!.postId!);
                      },
                    ),
                    SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0, // To position it on the right side
              child: Opacity(
                opacity: 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [],
                ),
              ),
            ),
            // ... Add other Positioned widgets for additional actions ...
          ],
        ),
      ),
    );
  }

  String formatDateString(DateTime? date) {
    if (date == null) {
      return 'No Date Provided';
    }

    // Format the DateTime object directly if it's not null.
    return DateFormat('y-MM-dd | HH:mm:ss').format(date);
  }

  Future<void> showCommentsDialog(BuildContext context, String postId) async {
    // Define the TextEditingController
    final TextEditingController commentController = TextEditingController();

    List<Comment> comments = await ApiCommentGet().fetchComments(postId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final EdgeInsets keyboardPadding = MediaQuery.of(context).viewInsets;
        final double availableHeight =
            screenHeight - keyboardPadding.bottom - 100;

        return Padding(
          padding: EdgeInsets.only(bottom: keyboardPadding.bottom),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: availableHeight *
                      0.9, // Allocate 70% of available height to comments list
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(comments[index].description),
                      subtitle: Text(
                        // This combines the createdAt and userName with a separator. If userName is null, it uses an empty string.
                        'Author: ${comments[index].userName ?? ''}',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller:
                        commentController, // Attach the TextEditingController
                    decoration: InputDecoration(
                      labelText: 'Post a comment',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          // Use the controller's text property to get the current value of the text field
                          if (commentController.text.isNotEmpty) {
                            await postComment(postId, commentController.text);
                            Navigator.of(context)
                                .pop(); // Close the bottom sheet
                            showCommentsDialog(context,
                                postId); // Optionally refresh the comments
                          }
                          commentController
                              .clear(); // Clear the text field after posting
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
