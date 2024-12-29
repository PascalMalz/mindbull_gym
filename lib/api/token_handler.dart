//Storage for access and refresh token to set and get
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:self_code/api/token_refresher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../callback_dispatcher_for_background_tasks.dart';

class TokenHandler {
  String _accessToken = '';
  String _refreshToken = '';

  VoidCallback? onTokenChange;

  @override
  initStatus (){
    print('TokenHandler initialized!');
    print("TokenHandler was called by: ");
    print(StackTrace.current);
  }


  TokenHandler() {
    initStatus();
    // Initialize with empty tokens
    initStatus();
    _loadTokensFromPrefs();
  }

  Future<void> _loadTokensFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken') ?? '';
    _refreshToken = prefs.getString('refreshToken') ?? '';
  }

  void registerLogin() {

    /* final TokenRefresher tokenRefresher = GetIt.instance.get<TokenRefresher>();
   tokenRefresher.initiateTokenRefreshTimers();*/
    // Initialize WorkManager with debug mode enabled
    print('void registerLogin() called');
    try {
      Workmanager().initialize(
        callbackDispatcher, // The top-level function which the plugin will call
        isInDebugMode: true, // Debug mode to show notification whenever a background task is triggered
      );

      // Registering a periodic background task for token refreshing
      Workmanager().registerPeriodicTask(
        "1",
        "tokenRefresher",
        frequency: Duration(
            minutes: 5), //15 min is the shortest allowed interval!
      );

      //todo how to find out if backgroundtask failed to activate the backup timer initiateTokenRefreshTimers?


      // If WorkManager task fails, revert to timer-based logic - not yet implemented


      try {
        TokenRefresher().initiateTokenRefreshTimers();
      } catch (err) {
        print('TokenHandler: tokenRefresher init initiateTokenRefreshTimers  failed');
      }


    }catch(err) {
      print('TokenHandler: Workmanager init failed');
    }
  }
  // Method to set the access token in the shared preferences to also have them available for background job
  Future<void> setAccessToken(String accessToken) async {
    _accessToken = accessToken;
    print("TokenHandler: accessToken set in token keeper: ${accessToken}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    onTokenChange?.call();  // Notify about change
  }

  // Method to get the access token
  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? _accessToken;
  }

  // Method to set the refresh token
  Future<void> setRefreshToken(String refreshToken) async {
    print("TokenHandler: refreshToken set in token keeper: ${refreshToken}");
    _refreshToken = refreshToken;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', refreshToken);

  }

  // Method to get the refresh token
  Future<String> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken') ?? _refreshToken;
  }

  // Method to check if the access token is available and valid
  bool isAccessTokenAvailableAndValid() {
    return _accessToken.isNotEmpty; // You can implement more validation logic here
  }

  // Method to check if the refresh token is available and valid
  bool isRefreshTokenAvailableAndValid() {
    return _refreshToken.isNotEmpty; // You can implement more validation logic here
  }

  // Method to handle token expiration or invalidation
  void handleTokenInvalidation(BuildContext context) {
    // You can implement actions to refresh the access token using the refresh token
    // and update the tokens here.
  }

// Other methods and properties as needed...
}
