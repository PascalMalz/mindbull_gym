import 'package:flutter/material.dart';
import '../api/api_follow_user.dart'; // Assuming this is the location of your ApiFollowUser
import '../main.dart';
import '../widgets/followers_card.dart'; // Reuse the same card for simplicity
import 'package:get_it/get_it.dart';

class FollowingListScreen extends StatefulWidget {
  final String? userId; // Now accepts nullable String

  FollowingListScreen({Key? key, this.userId}) : super(key: key);

  @override
  _FollowingListScreenState createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen> {
  late List<dynamic> _following; // List of following users
  bool _isLoading = true;
  ApiFollowUser apiFollowUser = getIt<ApiFollowUser>();

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _fetchFollowing();
    } else {
      // Handle the case where userId is null, perhaps setting loading to false and not attempting to fetch data
      _isLoading = false;
    }
  }

  // Fetching the list of users this user is following
  Future<void> _fetchFollowing() async {
    if (widget.userId == null) {
      print("User ID is null, cannot fetch following.");
      return;
    }
    ApiFollowUser apiFollowUser = GetIt.instance<ApiFollowUser>();
    try {
      List<dynamic> followingList = await apiFollowUser.fetchIFollowList(
          widget.userId!); // Adjust the method name accordingly
      setState(() {
        _following = followingList;
        _isLoading = false;
      });
    } catch (error) {
      print("Error fetching following: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _following.isEmpty
          ? Center(child: Text('No following found'))
          : RefreshIndicator(
        onRefresh: _fetchFollowing,
        child: ListView.builder(
          itemCount: _following.length,
          itemBuilder: (context, index) {
            return FollowerCard(
                follower: _following[index],
              trailing: IconButton(
                icon: Icon(Icons.person_remove, color: Colors.white),
                onPressed: () async {
                  await apiFollowUser.followUser(_following[index]['id']);
                  setState(() {});  // Ensure you have access to setState, or use other state management
                },
              ),
            ); // Using the same card for display
          },
        ),
      ),
    );
  }
}
