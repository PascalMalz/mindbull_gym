//provider to manage changes with the user login status like tokens --> TokenKeeper.
// any changes to the data within tokenApiKeeper are accessible through this instance of AuthProvider because it is declared in the main like this.
// todo sometimes the user is in the app authenticated but cannot make request why amd how to prevent?
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../api/token_handler.dart';
import '../api/token_refresher.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final TokenHandler _tokenHandler;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);


  AuthProvider(this._tokenHandler) {
    _tokenHandler.onTokenChange = notifyListeners;  // Set the callback in TokenApiKeeper
  }
  // Getter for the access token
  Future<String> get accessToken async => await _tokenHandler.getAccessToken();

  // Getter for the refresh token
  Future<String> get refreshToken async => await _tokenHandler.getRefreshToken();

  // Check if the user is logged in
  bool get isLoggedIn => _tokenHandler.isRefreshTokenAvailableAndValid();

  // Method to handle logout
  Future<bool> logout() async {
    try {
      // Log out from Google
      await _googleSignIn.signOut();


    // Clear tokens and notify listeners
    _tokenHandler.setAccessToken('');
    _tokenHandler.setRefreshToken('');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', '');
    await prefs.setString('refreshToken', '');
    //Cancel background tasks
    Workmanager().cancelAll(); //cancelByTag('tokenRefresher');
    // Cancel the token refresh timers
    final TokenRefresher tokenRefresher = GetIt.instance.get<TokenRefresher>();
    tokenRefresher.cancelTimers();
    notifyListeners();
    } catch (e) {
      //todo check if logout issue is resolved token refresher not registered in getIt
      print("AuthProvider: logout: Error during logout: $e");
    }
    return true;
  }
}
