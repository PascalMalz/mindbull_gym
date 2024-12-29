import 'package:flutter/material.dart';
import '../api/api_follow_user.dart'; // Assuming this is the location of your ApiFollowUser
import '../main.dart';
import '../widgets/followers_card.dart';
import 'package:get_it/get_it.dart';

class FollowersListScreen extends StatefulWidget {
  final String? userId; // Now accepts nullable String

  FollowersListScreen({Key? key, this.userId}) : super(key: key);

  @override
  _FollowersListScreenState createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen> {
  late List<dynamic> _followers;
  bool _isLoading = true;

  ApiFollowUser apiFollowUser = getIt<ApiFollowUser>();

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _fetchFollowers();
    } else {
      // Handle the case where userId is null, perhaps setting loading to false and not attempting to fetch data
      _isLoading = false;
    }
  }

  // Make sure to adjust your _fetchFollowers method to handle a nullable userId properly
  Future<void> _fetchFollowers() async {
    if (widget.userId == null) {
      print("User ID is null, cannot fetch followers.");
      return;
    }
    ApiFollowUser apiFollowUser = GetIt.instance<ApiFollowUser>();
    try {
      List<dynamic> followersList = await apiFollowUser.fetchFollowersList(widget.userId!); // Using ! because we checked it's not null
      setState(() {
        _followers = followersList;
        _isLoading = false;
      });
    } catch (error) {
      print("Error fetching followers: $error");
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
          : _followers.isEmpty
          ? Center(child: Text('No following found'))
          : RefreshIndicator(
        onRefresh: _fetchFollowers,
        child: ListView.builder(
          itemCount: _followers.length,
          itemBuilder: (context, index) {
            return FollowerCard(
                follower: _followers[index],
              trailing: Text('') ??
              IconButton(
                icon: Icon(Icons.person_remove, color: Colors.white),
                onPressed: () async {
                  await apiFollowUser.followUser(_followers[index]['id']);
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

