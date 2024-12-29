// This Dart file is responsible for refreshing the access token at specified intervals.
// It uses Dart's Timer class to handle the periodic tasks and calls methods to refresh the token.

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class TokenRefresher {

  late DateTime _nextAccessTokenRefresh;
  late Timer _accessTokenTimer;

  @override
  void initState() {
/*    initiateTokenRefreshTimers();*/
  }


  // Initiates the timer in case the background jobs fails
  void initiateTokenRefreshTimers() {
    print('TokenRefresher: initiateTokenRefreshTimers: called');
    _nextAccessTokenRefresh = DateTime.now().add(Duration(seconds: 20));
    startAccessTokenTimer();
  }
  // Cancel timers, e.g. on logout
  void cancelTimers() {
    _accessTokenTimer.cancel();
  }
  // Start a timer to refresh the access token every 24 hours
  void startAccessTokenTimer() {
    final durationUntilNextRefresh = _nextAccessTokenRefresh.difference(DateTime.now());
    _accessTokenTimer = Timer(durationUntilNextRefresh, () async {
      // Create SharedPreferences instance directly
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final String currentRefreshToken = prefs.getString('refreshToken') ?? '';
      final success = await refreshAccessAndRefreshToken(currentRefreshToken);
      if (success) {
        print("TokenRefresher: Access token refreshed successfully. 30sec");
        _nextAccessTokenRefresh = DateTime.now().add(Duration(minutes: 5));
        startAccessTokenTimer();
      }
    });
  }

}



// Method to manually refresh only the access token
Future<bool> refreshAccessAndRefreshToken(String currentRefreshToken) async {
  final Dio _dio = Dio();
  final String apiUrl = 'https://neurotune.de/sum/api/token/refresh/';

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  final Map<String, dynamic> body = {
    'refresh': currentRefreshToken,
  };

  if (currentRefreshToken.isEmpty) {
    print('TokenRefresher: refreshAccessToken: Token empty! currentRefreshToken: $currentRefreshToken');
    return false;
  }

  print('TokenRefresher: refreshAccessToken headers: $headers');
  try {
    final Response response = await _dio.post(
      apiUrl,
      options: Options(headers: headers),
      data: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = response.data;
      final String newAccessToken = responseData['access'] ?? '';
      final String newRefreshToken = responseData['refresh'] ?? '';

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.reload();
      prefs.setString('accessToken', newAccessToken);
      prefs.setString('refreshToken', newRefreshToken);

      print('TokenRefresher: refreshAccessToken: accessToken: $newAccessToken');
      return true;
    } else {
      return false;
    }
  } catch (error) {
    print("TokenRefresher: refreshAccessToken: Error refreshing access token: $error, $currentRefreshToken");
    return false;
  }
}