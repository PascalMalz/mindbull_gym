// This Flutter code navigates the user to the login screen if they are not logged in,
// and then navigates back to the original screen if the login is successful.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
//todo check if login is professional checked


class YourWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ElevatedButton(
          onPressed: () async {
            if (authProvider.isLoggedIn) {
              // User is logged in, proceed with the action
              print("User is logged in");
            } else {
              // Navigate to Login Page using named routes
              final result = await Navigator.pushReplacementNamed(
                context,
                '/authentication',
              );

              final bool didLogIn = result as bool? ?? false;

              // Check if login was successful, do something here if needed
              if (didLogIn) {
                Navigator.pop(context, true);
              }
            }
          },
          child: Text('Check if Logged In'),
        );
      },
    );
  }
}
