
import 'package:flutter/material.dart';
import '../api/api_follow_user.dart';
import '../main.dart';
import '../pages/profile.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Convert FollowerCard to a StatefulWidget to manage state changes
class FollowerCard extends StatefulWidget {
  final dynamic follower; // Expecting a Map with follower details
  final Widget trailing;   // Trailing widget to be passed for flexibility

  FollowerCard({Key? key, required this.follower, required this.trailing}) : super(key: key);

  @override
  _FollowerCardState createState() => _FollowerCardState();
}

class _FollowerCardState extends State<FollowerCard> {
  @override
  Widget build(BuildContext context) {
    ApiFollowUser apiFollowUser = getIt<ApiFollowUser>();
    print('follower: ${widget.follower}');
    print('follower url: ${widget.follower['profile_picture_url']}');

    return ListTile(
      leading: GestureDetector(
        onTap: () {
          print('userId: post?.userId: ${widget.follower['id']}');
          // Navigate to the profile page with the userId
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.follower['id'])),
          );
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(
            widget.follower['profile_picture_url'] as String? ?? "",
          ),
        ),
      ),
      title: GestureDetector(
          onTap: () {
            print('userId: post?.userId: ${widget.follower['id']}');
            // Navigate to the profile page with the userId
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.follower['id'])),
            );
          },
          child: Text(widget.follower['username'], style: TextStyle(color: Colors.white))),
      trailing: widget.trailing,
    );
  }
}

