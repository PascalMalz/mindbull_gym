
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
/*
const String googlePackageName = 'de.mindbull.mindbull';
const String googleApiKey = 'AIzaSyBDBFZfTx-cRJayiHQdSw2Nb6cG5D0Q8qA';

void main() {
  runApp(MaterialApp(
    home: Authentication_2(),
  ));
}


class GoogleSignInApi {
  static final _googleSingIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSingIn.signIn();
}

class Authentication_2 extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<Authentication_2> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final Dio _dio = Dio();


  Future<void> _handleSignIn(String provider) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print('test1');
    try {
      switch (provider) {
        case 'google':
          print('test2');
          print('test2${googlePackageName}');
          print('packageInfo.packageName: ${packageInfo.packageName}');


          print("_googleSignIn.clientId: ${_googleSignIn.clientId}");
          print("_googleSignIn.serverClientId: ${_googleSignIn.serverClientId}");


          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          print('test2_1');
          if (googleUser != null) {
            print('test3');
            final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
            String accessToken = googleAuth.accessToken ?? ''; // Using an empty string as a default value
            await _sendAccessTokenToBackend(accessToken);
            print('Signed in with Google: ${googleUser.displayName}');
          } else {
            print('test4');
            print('Google Sign-In canceled or failed.');
          }
          break;
      // Handle other providers here
        default:
          print('test5');
          print('Unknown provider');
          break;
      }
    } catch (error) {
      print('test6');
      print('Error signing in: $error');
      print("_googleSignIn.clientId: ${_googleSignIn.clientId}");
      print("_googleSignIn.serverClientId: ${_googleSignIn.serverClientId}");
    }
  }

  Future<void> _sendAccessTokenToBackend(String accessToken) async {
    final String apiUrl = 'YOUR_BACKEND_API_URL/auth/social/';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> requestBody = {
      'provider': 'google',
      'access_token': accessToken,
      'package_name': googlePackageName, // Hard-coded package name
      'api_key': googleApiKey, // Hard-coded API key
    };

    try {
      final Response response = await _dio.post(
        apiUrl,
        data: jsonEncode(requestBody),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print('Backend response: ${response.data}');
        // Process the backend response if needed
      } else {
        print('Backend request failed with status code ${response.statusCode}');
      }
    } catch (error) {
      print('_sendAccessTokenToBackend: Dio error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social Sign-In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => GoogleSignInApi.login(),
              child: Text('Sign In with Google Test'),
            ),
            // Add buttons for other providers here
          ],
        ),
      ),
    );
  }
}
*/
