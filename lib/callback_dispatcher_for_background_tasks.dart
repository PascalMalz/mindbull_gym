// callbackDispatcher for WorkManager (Background task)
import 'package:get_it/get_it.dart';
import 'package:self_code/services/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'api/token_handler.dart';
import 'api/token_refresher.dart';


// This is your callbackDispatcher function for WorkManager
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
//todo user logged out (because of something else than manual logout) but background job still running
//todo turn off debug
// This callbackDispatcher function is meant for WorkManager tasks
@pragma('vm:entry-point')
Future<void> callbackDispatcher() async {
  print('callbackDispatcher called');

  Workmanager().executeTask((task, inputData) async {
    bool taskSuccess = false;
    final logService = LogService();
    // Create SharedPreferences instance directly
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? totalExecutions = prefs.getInt("totalExecutions");
    final String currentRefreshToken = prefs.getString('refreshToken') ?? '';

    try {
      // Increment total executions count
      print('callbackDispatcher: Workmanager called');
      logService.writeLog('callbackDispatcher: Workmanager called ${DateTime.now()}');
      prefs.setInt("totalExecutions", totalExecutions == null ? 1 : totalExecutions + 1);

      // Call the API to refresh the token
      taskSuccess = await refreshAccessAndRefreshToken(currentRefreshToken);

    } catch(err) {
      logService.writeLog('Error on ${DateTime.now()}: $err');
      print('callbackDispatcher: Workmanager failed: ${err.toString()}'); // Prints error on the debug console
      taskSuccess = false;
    }

    return Future.value(taskSuccess);
  });
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
    print('callbackDispatcher: refreshAccessToken: Token empty! currentRefreshToken: $currentRefreshToken');
    return false;
  }

  print('callbackDispatcher: refreshAccessToken headers: $headers');
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
      await prefs.reload();
      prefs.setString('accessToken', newAccessToken);
      prefs.setString('refreshToken', newRefreshToken);
      final stored = prefs.getString('refreshToken');
      print('prefs.setString(refreshToken); $stored');
      print('callbackDispatcher:  refreshAccessToken: newRefreshToken: $newRefreshToken');
      return true;
    } else {
      return false;
    }
  } catch (error) {
    print("callbackDispatcher: refreshAccessToken: Error refreshing access token: $error");
    return false;
  }
}

