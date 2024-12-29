//todo adapt to be able to represent data for originate user as well as for random user profile call


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:self_code/pages/post/posts_audio_image_display_screen.dart';
import 'package:self_code/pages/profile_edit_page.dart';
import 'package:self_code/widgets/common_bottom_navigation_bar.dart';
import '../api/api_audio.dart';
import '../api/api_follow_user.dart';
import '../api/api_user_profile_upload.dart';
import '../main.dart';
import '../models/audio.dart';
import '../models/user.dart';
import '../provider/auth_provider.dart';
import '../provider/user_data_provider.dart';
import '../widgets/AudioFileTableWidget.dart';
import 'package:provider/provider.dart';

import '../widgets/followers_card.dart';
import 'followers_display_screen.dart';
import 'following_display_screen.dart';


class ProfilePage extends StatefulWidget {
  late String? userId;
  ProfilePage({Key? key, this.userId}) : super(key: key);


  @override
  _ProfilePageState createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  final ApiAudio _musicApi = ApiAudio();
  final ApiUserProfileUpload _apiUserProfileUpload = ApiUserProfileUpload();
  List<Audio> _audioFiles = [];
  late UserDataProvider userDataProvider;
  bool isUserDataLoaded = false;
  User? _calledProfileUser;

  @override
  void initState() {
    super.initState();
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    // Initially assume the profile user is the current user
    _calledProfileUser = userDataProvider.currentUser;
    // Check if we need to load another user's data
    if (widget.userId != null && widget.userId != userDataProvider.currentUser?.id) {
      userDataProvider.loadOtherUserData(widget.userId!).then((_) {
        // Once data is loaded, set _profileUser to the other user
        setState(() {
          _calledProfileUser = userDataProvider.getOtherUser(widget.userId!);
          print('called Profile user $_calledProfileUser');
        });
      }).catchError((error) {
        // Handle any errors appropriately
        print("Error loading other user's data: $error");
      });
    }

    _fetchAudioFilesForCategory(); // Assuming this doesn't need modification
  }
  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the UserDataProvider
    userDataProvider = Provider.of<UserDataProvider>(context);
    // Reload the user data to refresh the profile picture
    if (!isUserDataLoaded) {
      userDataProvider.loadUserData();
      isUserDataLoaded = true;  // Set the flag to true to avoid reloading
    }
  }

  File? _imageFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      setState(() {
        _imageFile = File(xFile.path);
      });

      // Now call the upload function
      final String? uploadResponse = await _apiUserProfileUpload.uploadImage(_imageFile!);
      if (uploadResponse == null) {
        // Successfully uploaded
        print("Image uploaded successfully.");
      } else {
        // Handle error
        print("Image upload failed: $uploadResponse");
      }
    }
  }


  Future<void> _fetchAudioFilesForCategory() async {
    try {
      final audioFiles = await _musicApi.fetchAudioFilesForCategory('All');
      setState(() {
        _audioFiles = audioFiles;
      });
    } catch (e) {
      print('Error fetching audio files: $e');
    }
  }



  void _deleteAudioFile(Audio audioFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this audio file?'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _musicApi.deleteMusic(
                    audioFile.id,
                    audioFile.clientAppAudioFilePath,
                    onSuccess: () {
                      // If the server deletion and file deletion are successful, remove from the local list
                      setState(() {
                        _audioFiles.remove(audioFile);
                      });
                      Navigator.of(context).pop();
                    },
                    onError: (error) {
                      // Handle error if deletion fails
                      print('Error deleting audio file: $error');
                      Navigator.of(context).pop();
                    },
                  );
                } catch (e) {
                  // Handle other errors that might occur during the deletion process
                  print('Error deleting audio file: $e');
                  Navigator.of(context).pop();
                }
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthenticationAction() {
    final user = userDataProvider.currentUser;
    if (user == null) {
      return
        IconButton(
          icon: Icon(Icons.login),
          onPressed: () async {
            await Navigator.pushNamed(context, '/authentication', arguments: {'redirectRoute': '/'});
            setState(() {});
          },
        );
    } else {
      return
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            Provider.of<AuthProvider>(context, listen: false).logout();
            setState(() {});
          },
        );
    }
  }





  @override
  Widget build(BuildContext context) {
    //Check if user who is calling is the owner of the profile todo is it secure to just pass the userid?
    User? currentUser = userDataProvider.currentUser;
   String? currentUserId = userDataProvider.currentUser?.id;
   final authProvider = Provider.of<AuthProvider>(context);
   final isLoggedIn = authProvider.isLoggedIn; // Assuming AuthProvider has an isLoggedIn property
   String? profileUser;
   print('widget.userId ${widget.userId}');
    if(widget.userId != null ){
      profileUser = widget.userId;
    } else{
      profileUser = currentUserId;
    }
    print('currentUser: $currentUserId, profileUser: $profileUser');
   final bool isOwnProfile = currentUserId == profileUser;
    //print('Url??? in build:${userDataProvider.user?.profilePictureUrl}');
    final user = userDataProvider.currentUser;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: Text('Profile'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
            //load buttons:
            if(isOwnProfile)
            _buildAuthenticationAction(), // Use the refactored method here.
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Consumer<UserDataProvider>(
                        builder: (context, userDataProvider, child) {
                          // Determine whether to use the current user's data or another user's data
                          print('profile load userProfile pic widget.userId: ${widget.userId}');
                          // This boolean directly tells us if we're viewing our own profile or another's.
                          final bool isOwnProfile = widget.userId == null || widget.userId == userDataProvider.currentUser?.id;
                          print("profile load userProfile pic isOwnProfile: $isOwnProfile");
                          // Decide which user's profile picture URL to use.
                          String? profileUrl = isOwnProfile ? userDataProvider.currentUser?.profilePictureUrl : userDataProvider.getOtherUser(widget.userId!)?.profilePictureUrl;
                          print('profile load userProfile pic profileUrl: $profileUrl');
                          // Validate if the profileUrl is valid
                          bool isValidUrl = Uri.tryParse(profileUrl ?? '')?.hasAbsolutePath ?? false;

                          ImageProvider imageProvider;

                          if (_imageFile != null && widget.userId == userDataProvider.currentUser?.id) {
                            // If there's a selected image file, and it's the current user's profile
                            imageProvider = FileImage(_imageFile!) as ImageProvider;
                          } else if (isValidUrl) {
                            imageProvider = NetworkImage(profileUrl!) as ImageProvider;
                          } else {
                            imageProvider = AssetImage('assets/default_profile_picture.png') as ImageProvider; // Default image
                          }
// Return a CircleAvatar with conditional onTap action
                          return InkWell(
                            onTap: isOwnProfile
                                ? _pickImage // If it's the own profile, allow image change.
                                : () {
                              // Here you can define what happens when tapping on another user's profile.
                              // For example, navigate to a detailed profile view:
                              // Navigator.of(context).pushNamed('/user-profile', arguments: widget.userId);
                              // Or simply do nothing.
                            },
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: imageProvider,
                            ),
                          );

                        },
                      ),



                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Include user profile information here
                          Consumer<UserDataProvider>(
                            builder: (context, userDataProvider, child) {
                              final bool isOwnProfile = widget.userId == null || widget.userId == userDataProvider.currentUser?.id;
                              print("profile load userProfile pic isOwnProfile: $isOwnProfile");
                              // Decide which user's profile picture URL to use.
                              try {
                              } on Exception catch (e, s) {
                                print(s);
                              }
                              String? userName = isOwnProfile ? userDataProvider.currentUser?.username : userDataProvider.getOtherUser(widget.userId!)?.username;

                              if (user != null) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName  ?? 'Default Username', // Replace with the actual user display name
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text('Bio goes here',style: TextStyle(
                                      color: Colors.white,
                                    ),),
                                    if(isOwnProfile)
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileEditPage()));
                                        },
                                        child: Text('Edit Profile'),
                                      ),
                                    if(isOwnProfile)
                                    Text(
                                      '${_calledProfileUser?.followersCount ?? 0} followers | ${_calledProfileUser?.followingCount ?? 0} following',
                                      style: TextStyle(color: Colors.grey, fontSize: 16),
                                    ),
                                    //if(notYetFollowed)
                                    if(!isOwnProfile)
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              ApiFollowUser apiFollowUser = getIt<ApiFollowUser>();
                                              try {
                                                await apiFollowUser.followUser(widget.userId.toString());
                                                // Toggle the follow status and update the follower count accordingly
                                                setState(() {
                                                  // Toggle the current follow status
                                                  bool isCurrentlyFollowed = _calledProfileUser?.isFollowedByUser ?? false;
                                                  _calledProfileUser?.isFollowedByUser = !isCurrentlyFollowed;

                                                  // Adjust the follower count based on the new follow status
                                                  if (_calledProfileUser?.isFollowedByUser == true) {
                                                    _calledProfileUser?.followersCount = (_calledProfileUser?.followersCount ?? 0) + 1;
                                                  } else {
                                                    _calledProfileUser?.followersCount = (_calledProfileUser?.followersCount ?? 0) - 1;
                                                  }
                                                });
                                                print("Follow status toggled successfully.");
                                              } catch (error) {
                                                print("Error toggling follow status: $error");
                                              }
                                            },
                                            child:
                                                Text(_calledProfileUser?.isFollowedByUser == true ? 'Unfollow' : 'Follow'),



                                          ),
                                          Text(
                                            '${_calledProfileUser?.followersCount ?? 0} followers | ${_calledProfileUser?.followingCount ?? 0} following',
                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                          ),
                                        ],
                                      ),

                                  ],
                                );
                              } else {
                                // Handle the case when user data is not available
                                return Text('Login to view / edit your profile',style: TextStyle(
                                  color: Colors.white,
                                ),);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.deepPurple)),
                    ),
                    child: TabBar(
                      isScrollable: false,
                      labelPadding: EdgeInsets.zero,
                      tabs: [
                        Tab(text: 'Posts'),
                        Tab(text: ''
                            'I Like'),
                        Tab(text: 'Followers'),
                        Tab(text: 'Following'),
                      ],
                      indicatorColor: Colors.deepPurple,
                      labelColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  isLoggedIn
                      ? PostsAudioImageDisplayScreen(
                    autoplayEnabled: false, // Or dynamically set based on user preferences
                    userId: widget.userId ?? currentUserId, // Pass the current or specified user's ID
                    // Optionally, you could also pass tags, category, characteristics if needed
                  )
                      : LoginPromptMessage(),
                  isLoggedIn
                      ? PostsAudioImageDisplayScreen(
                    autoplayEnabled: false, // Or dynamically set based on user preferences
                    userId: widget.userId ?? currentUserId, // Pass the current or specified user's ID
                    showLikedPostsOnly: true,
                  )
                      : LoginPromptMessage(),
                  isLoggedIn ? FollowersListScreen(userId: widget.userId) : LoginPromptMessage(),
                  isLoggedIn ? FollowingListScreen(userId: widget.userId) : LoginPromptMessage(),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

}




class LoginPromptMessage extends StatelessWidget {
  final String message;

  const LoginPromptMessage({
    Key? key,
    this.message = "You have to log in to view/edit this section",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


class MusicPostCard extends StatelessWidget {
  final String imageUrl;
  final String username;
  final String postText;
  final double averageRating; // Placeholder value
  final ApiUserProfileUpload _apiUserProfileUpload = ApiUserProfileUpload();
  late UserDataProvider userDataProvider;




  MusicPostCard({
    required this.imageUrl,
    required this.username,
    required this.postText,
    this.averageRating = 4.5, // Placeholder value
  });



  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple,
      child: Column(
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
            ),
            title: Text(username),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.yellow),
                Text(averageRating.toString()),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Text(postText),
          ),
        ],
      ),
    );
  }
}


