//provider to load the data of a user as soon as he is logged in

import 'package:flutter/cupertino.dart';
import '../api/api_follow_user.dart';
import '../api/api_user_data.dart';
import '../main.dart';
import '../models/user.dart';
import 'auth_provider.dart';

class UserDataProvider with ChangeNotifier {
  User? _currentUser;
  Map<String, User?> _otherUsers = {}; // Cache other users' data
  final AuthProvider _authProvider;

  UserDataProvider(this._authProvider) {
    print('UserDataProvider constructor called. Caller stack trace:');
    print(StackTrace.current);
    _authProvider.addListener(() async {
      // Check not only for login but also for logout and act accordingly
      if (await _authProvider.isLoggedIn) {
        loadUserData();
      } else {
        print('UserDataProvider constructor -> set user to null');
        _currentUser = null;
        notifyListeners();  // To update UI that user data is now null
      }
    });
  }

  User? get currentUser => _currentUser;

  Future<void> loadUserData() async {
    final accessToken = await _authProvider.accessToken;
    try {
      final userData = await fetchUserProfile(accessToken as String);
      final profilePictureUrl = userData['profile_picture_url'];

      final username = userData['username'];
      print('UserDataProvider loadUserData username: $username');
      final email = userData['email'];
      final id = userData['id'];
      final followersCount = userData['followers_count'];
      final followingCount = userData['following_count'];
      // Now you have the profile picture URL, username, and email to update the UserDataProvider.
      _currentUser = User(
        username: username,
        email: email,
        profilePictureUrl: profilePictureUrl,
        id: id,
        followersCount : followersCount,
        followingCount : followingCount,
        isFollowedByUser: false  // Default to false initially
      );

      // Notify listeners to update the UI.
      notifyListeners();
      // Print the user object for debugging
      print('UserDataProvider: User Data Loaded in user_data_provider: $_currentUser');
    } catch (e) {
      //todo why user is not authenticated with social login on first try?
      print('UserDataProvider had an exception: $e');
      // Handle errors, e.g., network errors or failed API requests.
    }
  }

  // Get other user's data
  User? getOtherUser(String userId) => _otherUsers[userId];

  // Load another user's data by ID
  Future<void> loadOtherUserData(String userId) async {
    print('loadOtherUserData start');

      try {
        // Example fetching logic
        final accessToken = await _authProvider.accessToken;
        print('loadOtherUserData accessToken: $accessToken userId: $userId');

        final userData = await fetchOtherUserProfile(accessToken as String, userId);
        print('userData. $userData');
        // Assuming fetchUserProfileForId returns similar data structure
        final profilePictureUrl = userData['profile_picture_url'];
        final username = userData['username'];
        final email = userData['email'];
        final id = userData['id'];
        final followersCount = userData['followers_count'];
        final followingCount = userData['following_count'];


        _otherUsers[id] = User(
            username: username,
            email: email,
            profilePictureUrl: profilePictureUrl,
            id: id,
            followersCount : followersCount,
            followingCount : followingCount,
            isFollowedByUser: false  // Default to false initially
        );

        // Now fetch the follow status
        await _checkFollowStatus(id);

        notifyListeners(); // Notify to refresh UI if needed
      } catch (e) {
        print('Error loading other user data: $e');
        // Handle errors

    }
  }

  Future<void> _checkFollowStatus(String userId) async {
    ApiFollowUser apiFollowUser = getIt<ApiFollowUser>();
    try {
      bool isFollowedByUser = await apiFollowUser.checkFollowStatus(userId);
      if (_otherUsers.containsKey(userId)) {
        // Correctly updating the user object in the map
        var user = _otherUsers[userId];
        if (user != null) {
          // Create a new User object with updated data
          _otherUsers[userId] = User(
              username: user.username,
              email: user.email,
              profilePictureUrl: user.profilePictureUrl,
              id: user.id,
              followersCount: user.followersCount,
              followingCount: user.followingCount,
              isFollowedByUser: isFollowedByUser // Correctly update follow status
          );
          notifyListeners(); // Notify listeners to update the UI
        }
      }
    } catch (e) {
      print('Error checking follow status for user $userId: $e');
    }
  }



  // Optional: Clear other users' data if necessary, e.g., on logout
  void clearOtherUsersData() {
    _otherUsers.clear();
    notifyListeners();
  }


}
