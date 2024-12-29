//Login through social authentication with e.g. google, facebook, ... ect.
//Set access and refresh token

//todo  not working with gmail and existing account at this moment because email is already registered so the new user cannot be created.

//todo Also a simple login is not possible (oly with registration (user name input appears) so this username input screen must come after check if user for this google email exists.
//todo sign out from google must be properly handled
//todo dont send email notification if signed in with google
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:self_code/api/token_handler.dart';

import '../clear_user_data_processes.dart';

import 'api_auth_check_email.dart';

//

class ApiAuthSocialLoginAndRegistration {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final Dio _dio = Dio();
  final TokenHandler tokenApiKeeper; // Inject the token manager
  ApiAuthSocialLoginAndRegistration(this.tokenApiKeeper);
  String username = 'none';



  Future<bool> handleSocialLogin() async {
    print('Handle signOut starting');
    await handleSignOut();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    print('_googleSignIn.signIn() try finished');
    if (googleUser != null) {
      // Check if user exists by email
      String email = googleUser.email;
      String userExists = await ApiAuthCheckEmail().checkEmailAvailability(email); //need the username from here
      print('userExists: $userExists');
      if (userExists=='Email already registered, please try another one.') {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        String idToken = googleAuth.idToken ?? '';
        String accessToken = googleAuth.accessToken ?? '';
        print('ApiAuthSocialLoginAndRegistration handleSignIn idToken: $idToken');
        print('ApiAuthSocialLoginAndRegistration handleSignIn accessToken: $accessToken');


        await _sendAccessTokenToBackend(accessToken, idToken, username);
        print('ApiAuthSocialLoginAndRegistration handleSignIn Signed in with Google: ${googleUser.displayName}');
        String googleUsername=googleUser.displayName!;
        print('googleUsername: $googleUsername');
        return true;

      } else {
        print('ApiAuthSocialLoginAndRegistration handleSignIn else1');
        print('ApiAuthSocialLoginAndRegistration handleSignIn Google Sign-In canceled or failed.');
        return false;
      }
    }else {
      return false;
    }

  }


  Future<bool> handleSignIn(String? provider, String username) async {
    print('ApiAuthSocialLoginAndRegistration handleSignIn start');
    try {
      switch (provider) {
        case 'google':
          print('ApiAuthSocialLoginAndRegistration handleSignIn provider = google');

          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser != null) {
            final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
            String idToken = googleAuth.idToken ?? '';
            String accessToken = googleAuth.accessToken ?? '';
            print('ApiAuthSocialLoginAndRegistration handleSignIn idToken: $idToken');
            print('ApiAuthSocialLoginAndRegistration handleSignIn accessToken: $accessToken');


            await _sendAccessTokenToBackend(accessToken, idToken, username);
            print('ApiAuthSocialLoginAndRegistration handleSignIn Signed in with Google: ${googleUser.displayName}');
            username=googleUser.displayName!;
            return true;

          } else {
            print('ApiAuthSocialLoginAndRegistration handleSignIn else');
            print('ApiAuthSocialLoginAndRegistration handleSignIn Google Sign-In canceled or failed.');
            return false;
          }
        default:
          print('ApiAuthSocialLoginAndRegistration handleSignIn default');
          print('ApiAuthSocialLoginAndRegistration handleSignIn Unknown provider');
          return false;
      }
    } catch (error) {
      print('ApiAuthSocialLoginAndRegistration handleSignIn error');
      print('ApiAuthSocialLoginAndRegistration handleSignIn Error signing in: $error');
      return false;
    }
  }


  Future<void> _sendAccessTokenToBackend(String accessToken, String idToken, String username ) async {
    final String apiUrl = 'https://neurotune.de/sum/auth/social/';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> requestBody = {
      'provider': 'google',
      'access_token': accessToken,
      'id_token' : idToken,
      'username' : username,
    };
  print('_sendAccessTokenToBackend google accessToken: $accessToken , idToken: $idToken');
    print('_sendAccessTokenToBackend requestBody: $requestBody ,headers: $headers');
    try {
      final Response response = await _dio.post(
        apiUrl,
        data: jsonEncode(requestBody),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print('Backend response: ${response.data}');
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        final String refreshToken = responseData['refresh'] ?? '';
        final String accessToken = responseData['access'] ?? '';
        print('ApiAuthSocialLoginAndRegistration _sendAccessTokenToBackend: user authenticated with social login refreshToken: $refreshToken , accessToke: $accessToken');
        tokenApiKeeper.setRefreshToken(refreshToken); // Store the refresh token
        tokenApiKeeper.setAccessToken(accessToken); // Store the access token
        print('ApiAuthNativeLogin: User authenticated with native login. accessToken: $accessToken, refreshToken: $refreshToken ');
        ClearUserDataProcess().clearJobs();
        tokenApiKeeper.registerLogin();
        // Process the backend response if needed
      } else {
        print('Backend request failed with status code ${response.statusCode}');
      }
    } catch (error) {
      print('_sendAccessTokenToBackend: Dio error: $error');
    }
  }

  Future<void> handleSignOut() async {
    try {
      await _googleSignIn.signOut();
      print('ApiAuthSocialLoginAndRegistration handleSignOut Signed out from Google');
    } catch (error) {
      print('ApiAuthSocialLoginAndRegistration handleSignOut Error signing out: $error');
    }
/*    setState(() {
      username='';
    });*/
  }
}