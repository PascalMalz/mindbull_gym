//todo message when credentials are wrong
//todo as login and sign in is async wait until finish to push to next page
//todo only allow login if email is confirmed
//todo add field error when nothing is filled and the button login / sign-in is clicked
//todo Put username field and check on next page after registration with email and password
//todo repair signup with google if user name exists.
//todo send error message when already logged in with user e.g. google sign in
//todo add proper terms and conditions
//todo delete files and functions not needed anymore
//todo for facebook auth I need to verify with own business. I don't have one yet for this app
//todo validate email
//todo uncomment facebook and twitter code when configured
//todo explain why username is needed
//todo different when user already exists with social sign in
//todo login error messages
//todo bring UsernameInputScreen and UsernameInputScreenSocial together
//todo Registration failed: registration successful to be checked what happened there.
//todo Implement error messages when API fails!
//todo Implement proper final registration message
//todo social login should login user when already registered. Not directly forward to set username...
//todo Show error message when login failed
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_auth_check_email.dart';
import '../api/api_auth_check_username.dart';
import '../api/api_auth_native_login.dart';
import '../api/api_auth_nativ_registration.dart';
import '../api/api_auth_social_login_and_registration.dart';
import '../api/token_handler.dart';
import '../clear_user_data_processes.dart';
import '../main.dart';
import '../models/user.dart';
import '../pages/home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../policies/policy_content.dart';
import '../provider/auth_provider.dart';
import '../provider/user_data_provider.dart';

class CustomLoginScreen extends StatefulWidget {

  final bool isSignUp;

  CustomLoginScreen({this.isSignUp = false});

  @override
  _CustomLoginScreenState createState() => _CustomLoginScreenState();
}


class _CustomLoginScreenState extends State<CustomLoginScreen> {
  final authProvider = getIt.get<AuthProvider>();
  final tokenApiKeeper = getIt.get<TokenHandler>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? emailErrorText;
  String? passwordErrorText;
  bool loggedIn = false;
  String? redirectRoute;  // Declare it here

  @override
  void initState() {
    super.initState();

    final authProvider = getIt.get<AuthProvider>();

    if (authProvider.isLoggedIn) {
      authProvider.logout();
      print('You are already logged in!');
      return;
    }
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      redirectRoute = args['redirectRoute'] ?? '/defaultRoute';
    });
  }


  // Function to handle signup logic
  Future<bool?> _handleSignup({String? loginMethod, String? authProvider}) async {
    if (loginMethod == 'social') {
      print('Calling UsernameInputScreenSocial :$authProvider');
      //check here first if an user already exist for that social account and log in
      bool existingAccount = await socialAuth.handleSocialLogin();
      //todo problem when logging in with the user the data uis not automatically loaded (try with userDataProvider?) and sometimes it happens that the login with any email does not work but then with the next try
      //todo problem probably because of the unauthorized access.
      if (existingAccount == true){
        final userDataProvider = getIt.get<UserDataProvider>();
        userDataProvider.loadUserData();
        Navigator.pop(context, userDataProvider.currentUser?.id); // Close the dialog
      } else if ((existingAccount == false)){
        Navigator.of(context).pop();
      } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UsernameInputScreenSocial(authenticationProvider: authProvider),
        ),
      );
    }
    } else {
      // Validate the email field
      final emailField = EmailField(controller: emailController);
      setState(() {
        emailErrorText = emailField.validate(emailController.text);
      });

      // Validate the password field
      final passwordField = PasswordField(controller: passwordController);
      setState(() {
        passwordErrorText = passwordField.validate(passwordController.text);
      });


      // Check if all fields are valid
      if (emailErrorText == null && passwordErrorText == null) {
        //Check if username exists in backend:
        String emailAvailable = await ApiAuthCheckEmail().checkEmailAvailability(emailController.text);

        if(emailAvailable == 'Email available'){
          // All fields are valid, proceed with signup logic
          print('Start sign up');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UsernameInputScreen(
                    email: emailController.text,
                    password: passwordController.text,
                    authenticationType: 'native', // Pass the authentication type
                  ),
            ),
          );
          //_handleRegistration();

        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(emailAvailable),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Display an error message if any field is empty
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all fields.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // Function to navigate to signup page
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(redirectRoute: redirectRoute),
      ),
    );
  }

  // Function to handle social login with the selected provider
  void _handleSocialLogin(String providerName) async{
    print('Logging in with $providerName');
    _handleSignup(loginMethod: 'social', authProvider: providerName);
  }

  // Helper function to create a social login button or "Create New Account" button
  Widget _buildButton(String text, String? customIconPath, {VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIconPath != null)
              SvgPicture.asset( // Use SvgPicture.asset to load SVG icons
                customIconPath,
                //color: Colors.black87,
                width: 32,
                height: 32,
              ),
            if (customIconPath != null) SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }


  final socialAuth = getIt<ApiAuthSocialLoginAndRegistration>();



  @override
  Widget build(BuildContext context) {
    final authProvider = getIt.get<AuthProvider>();
    return authProvider.isLoggedIn
      ? Text('Welcome, User!')
    :
      Scaffold(
        //backgroundColor: Colors.grey.shade900,
        backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4.0, // Add elevation for a shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                  side: BorderSide(color: Colors.white, width: 2.0), // Border color and width
                ),
                color: Colors.deepPurple,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create new account',
                            style: TextStyle(color: Colors.greenAccent,fontSize: 16),
                          ),
                          Icon(Icons.lock_person, color: Colors.greenAccent,)
                        ],
                      ),
                      EmailField(
                        controller: emailController,
                        hintText: 'Enter your email address',
                        labelText: 'Email',
                      ),
                      PasswordField(
                        controller: passwordController,
                        hintText: 'Enter your initial password',
                        labelText: 'Set Password',
                      ),
                      SizedBox(height: 20),
                      FloatingActionButton.extended(
                        heroTag: 'hero_6',
                        onPressed: _handleSignup,
                        label: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        icon: Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Add social login buttons here
              Column(
                children: [
                  _buildButton('Sign in with Google', 'assets/Google__G__Logo.svg', onPressed: () async{
                    _handleSocialLogin('google');
                  }),
/*                  SizedBox(height: 20),
                  _buildButton('Sign in with Facebook', 'assets/2021_Facebook_icon.svg', onPressed: () async{
                    _handleSocialLogin('facebook');
                  }),
                  SizedBox(height: 20),
                  _buildButton('Sign in with Twitter', 'assets/twitter_logo.svg', onPressed: () async{
                    _handleSocialLogin('twitter');
                  }),*/
                ],
              ),

              SizedBox(height: 20), // Add spacing between "Create New Account" button and text

              Divider(
                thickness: 1.0, // Adjust the thickness of the divider
                color: Colors.white, // Adjust the color of the divider
              ),
              SizedBox(height: 10),
              Text(
                'Already have an account?',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              // Login styled button
              _buildButton(
                'Log In',
                null, // No icon for this button
                onPressed: () {
                  _navigateToLogin(); // Call the login or signup function
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class UsernameInputScreen extends StatefulWidget {
  final String email;
  final String password;
  final String authenticationType; // Add this parameter

  UsernameInputScreen({
    required this.email,
    required this.password,
    required this.authenticationType,
  });

  @override
  _UsernameInputScreenState createState() => _UsernameInputScreenState();
}


class _UsernameInputScreenState extends State<UsernameInputScreen> {
  TextEditingController usernameController = TextEditingController();
  String? usernameErrorText;


  // Function to handle signup logic
  Future<void> _checkUserName() async {
    // Validate the username field
    final usernameField = UsernameField(controller: usernameController);
    setState(() {
      usernameErrorText = usernameField.validate(usernameController.text);
    });

    // Check if all fields are valid
    if (usernameErrorText == null) {
      //Check if username exists in backend:
      String userAvailable = await ApiAuthCheckUsernameAvailability().checkUsernameAvailability(usernameController.text);

      if(userAvailable == 'Username available'){
        // All fields are valid, proceed with signup logic
        print('Set user name');
        final username = usernameController.text;
        _showTermsAndConditions(username);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userAvailable),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else{
      // Display an error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in your username properly.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  // Function to show terms and conditions dialog
  Future<void> _showTermsAndConditions(String username) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          scrollable: true,
          //title: Center(child: Text('Terms and Conditions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),),),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ... (other text fields)
              SizedBox(height: 16),

              Text(
                'By clicking on "Complete Registration," you agree to MindBull\'s account creation and the following:',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Terms and Conditions
              _buildClickableText(
                'Terms & Conditions',
                    () {
                  _showPolicyPopup(context, 'Terms & Conditions');
                  // Navigate to the Terms and Conditions page
                  // Use Navigator.push here to go to a WebView or another screen.
                },
              ),
              SizedBox(height: 16),

              // Data Privacy
              Text(
                'and',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              _buildClickableText(
                'Data Privacy Policy',
                    () {
                  _showPolicyPopup(context, 'Data Privacy Policy');
                  // Navigate to the Data Privacy page
                  // Use Navigator.push here to go to a WebView or another screen.
                },
              ),
              SizedBox(height: 16),

              Text(
                'as well as our',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              _buildClickableText(
                'Cookie Policy',
                    () {
                  _showPolicyPopup(context, 'Cookie Policy');
                  // Navigate to the Cookie Policy page
                  // Use Navigator.push here to go to a WebView or another screen.
                },
              ),
              SizedBox(height: 30),

              FloatingActionButton.extended(
                heroTag: 'hero_1',
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _handleRegistration(username); // Proceed with registration
                },
                label: Text(
                  'Complete Registration',
                  style: TextStyle(fontSize: 16.0),
                ),
                icon: Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        );
      },
    );
  }

// Helper method to create clickable text
  Widget _buildClickableText(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          decoration: TextDecoration.underline,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _showPolicyPopup(BuildContext context, String policyTitle) async {
    // Find the corresponding policy content based on the title
    final PolicyContent policy = policies.firstWhere(
          (policy) => policy.title == policyTitle,
      orElse: () => PolicyContent('', ''),
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          scrollable: true,
          title: Center(
            child: Text(
              policy.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              policy.content,
              style: TextStyle(fontSize: 18),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }




  Future<void> _handleRegistration(String userName) async {
    String email = widget.email;
    String password = widget.password;
    String username = userName;

    print('Registration?');
    debugPrint('Email: ${email}, Password: ${password}, username: ${username}');

    final registrationAPI = getIt<ApiAuthNativeRegistration>(); // Get the registered instance
    final registrationResult = await registrationAPI.registerUser(email, password, username);
    print('registrationResult: $registrationResult');
    if (registrationResult == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please confirm your email to activate your user.'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the pop-up
                    Navigator.pop(context); // Close the AdditionalDetailsScreen
                  },
                  child: Text('Proceed'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Show an error message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $registrationResult'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade900,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Set Username'),
        backgroundColor: Colors.transparent,
      ),
      body:
      ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4.0, // Add elevation for a shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                  side: BorderSide(color: Colors.black12, width: 2.0), // Border color and width
                ),
                color: Colors.deepPurple,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Please set an username. The username will be neccessary to find your profile and can be displayed for social interactions. The length must be at least 5 characters.', style: TextStyle(color: Colors.greenAccent),),
                      SizedBox(height: 20),
                      UsernameField(
                        controller: usernameController,
                        hintText: 'Enter your username',
                        labelText: 'Username',
                      ),
                      SizedBox(height: 20),
                      FloatingActionButton.extended(
                        heroTag: 'hero_2',
                        onPressed: _checkUserName,
                        label: Text(
                          'Submit',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        icon: Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UsernameInputScreenSocial extends StatefulWidget {
  final String? authenticationProvider;

  UsernameInputScreenSocial({
    this.authenticationProvider,
  });

  @override
  _UsernameInputScreenSocialState createState() => _UsernameInputScreenSocialState();
}


class _UsernameInputScreenSocialState extends State<UsernameInputScreenSocial> {
  TextEditingController usernameController = TextEditingController();
  String? usernameErrorText;

  //If email is already registered login with that user.
  //call here ApiAuthSocialLoginAndRegistration

  // Function to handle signup logic
  Future<void> _checkUserName() async {
    // Validate the username field
    final usernameField = UsernameField(controller: usernameController);
    setState(() {
      usernameErrorText = usernameField.validate(usernameController.text);
    });

    // Check if all fields are valid
    if (usernameErrorText == null) {
      //Check if username exists in backend:
      String userAvailable = await ApiAuthCheckUsernameAvailability().checkUsernameAvailability(usernameController.text);

      if(userAvailable == 'Username available'){
        // All fields are valid, proceed with signup logic
        print('Set user name');
        final username = usernameController.text;
        _showTermsAndConditions(username);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userAvailable),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else{
      // Display an error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in your username properly.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Function to show terms and conditions dialog
  Future<void> _showTermsAndConditions(String username) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          scrollable: true,
          //title: Center(child: Text('Terms and Conditions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),),),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ... (other text fields)
              SizedBox(height: 16),

              Text(
                'By clicking on "Complete Registration," you agree to MindBull\'s account creation and the following:',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Terms and Conditions
              _buildClickableText(
                'Terms & Conditions',
                    () {
                  _showPolicyPopup(context, 'Terms & Conditions');
                  // Navigate to the Terms and Conditions page
                  // Use Navigator.push here to go to a WebView or another screen.
                },
              ),
              SizedBox(height: 16),

              // Data Privacy
              Text(
                'and',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              _buildClickableText(
                'Data Privacy Policy',
                    () {
                  _showPolicyPopup(context, 'Data Privacy Policy');
                  // Navigate to the Data Privacy page
                  // Use Navigator.push here to go to a WebView or another screen.
                },
              ),
              SizedBox(height: 16),

              Text(
                'as well as our',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              _buildClickableText(
                'Cookie Policy',
                    () {
                      _showPolicyPopup(context, 'Cookie Policy');
                  // Navigate to the Cookie Policy page
                  // Use Navigator.push here to go to a WebView or another screen.
                },
              ),
              SizedBox(height: 30),

              FloatingActionButton.extended(
                heroTag: 'hero_1',
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _handleRegistration(username); // Proceed with registration
                },
                label: Text(
                  'Complete Registration',
                  style: TextStyle(fontSize: 16.0),
                ),
                icon: Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        );
      },
    );
  }

// Helper method to create clickable text
  Widget _buildClickableText(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          decoration: TextDecoration.underline,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _showPolicyPopup(BuildContext context, String policyTitle) async {
    // Find the corresponding policy content based on the title
    final PolicyContent policy = policies.firstWhere(
          (policy) => policy.title == policyTitle,
      orElse: () => PolicyContent('', ''),
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          scrollable: true,
          title: Center(
            child: Text(
              policy.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              policy.content,
              style: TextStyle(fontSize: 18),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _handleRegistration(String userName) async {
  //todo handle new user creation when not exists.
    String username = userName;

    print('Registration?');
    debugPrint('Username: ${username}');

    final socialAuth = getIt<ApiAuthSocialLoginAndRegistration>(); // Get the registered instance
    final registrationResult = await socialAuth.handleSignIn(widget.authenticationProvider, userName);
    print('registrationResult: $registrationResult');
    if (registrationResult == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please confirm your email to activate your user.'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the pop-up
                    Navigator.pop(context); // Close the AdditionalDetailsScreen
                  },
                  child: Text('Proceed'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Show an error message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $registrationResult'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade900,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Set Username'),
        backgroundColor: Colors.transparent,
      ),
      body:
      ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4.0, // Add elevation for a shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                  side: BorderSide(color: Colors.white, width: 2.0), // Border color and width
                ),
                color: Colors.deepPurple,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Please set an username. The username will be neccessary to find your profile and can be displayed for social interactions. The length must be at least 5 characters.', style: TextStyle(color: Colors.greenAccent),),
                      SizedBox(height: 20),
                      UsernameField(
                        controller: usernameController,
                        hintText: 'Enter your username',
                        labelText: 'Username',
                      ),
                      SizedBox(height: 20),
                      FloatingActionButton.extended(
                        heroTag: 'hero_4',
                        onPressed: _checkUserName,
                        label: Text(
                          'Submit',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        icon: Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}







// Signup Page
class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  String? emailErrorText;
  String? passwordErrorText;
  String? usernameErrorText;


  // Function to handle signup logic
  Future<void> _handleSignup() async {
    // Validate the email field
    final emailField = EmailField(controller: emailController);
    setState(() {
      emailErrorText = emailField.validate(emailController.text);
    });

    // Validate the password field
    final passwordField = PasswordField(controller: passwordController);
    setState(() {
      passwordErrorText = passwordField.validate(passwordController.text);
    });

    // Validate the username field
    final usernameField = UsernameField(controller: usernameController);
    setState(() {
      usernameErrorText = usernameField.validate(usernameController.text);
    });

    // Check if all fields are valid
    if (emailErrorText == null && passwordErrorText == null && usernameErrorText == null) {
      // All fields are valid, proceed with signup logic
      print('Start sign up');
      _handleRegistration();

    }
  }

  Future<void> _handleRegistration() async {
    String email = emailController.text;
    String password = passwordController.text;
    String username =  usernameController.text;

    print('Registration?');
    debugPrint('Email: ${email}, Password: ${password}');

    final registrationAPI = getIt<ApiAuthNativeRegistration>();
    final registrationResult = await registrationAPI.registerUser(email, password, username);
    print(registrationResult);
    if (registrationResult == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please confirm your email to activate your user.'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the pop-up
                    Navigator.pop(context); // Close the AdditionalDetailsScreen
                  },
                  child: Text('Proceed'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Show an error message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $registrationResult'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade900,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmailField(
              controller: emailController,
              hintText: 'Enter your email address',
              labelText: 'Email',
            ),
            SizedBox(height: 10),
            PasswordField(
              controller: passwordController,
              hintText: 'Enter your password',
              labelText: 'Password',
            ),
            SizedBox(height: 10),
            UsernameField(
              controller: usernameController,
              hintText: 'Enter your username',
              labelText: 'Username',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSignup,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

// Login Page
class LoginPage extends StatefulWidget {
  final String? redirectRoute;
  LoginPage({required this.redirectRoute});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  String? emailErrorText;
  String? passwordErrorText;



  // Function to handle login or signup logic
  Future<void> _handleAuth() async {
      // Validate the email field
      final emailField = EmailField(controller: emailController);
      setState(() {
        emailErrorText = emailField.validate(emailController.text);
      });

      // Validate the password field
      final passwordField = PasswordField(controller: passwordController);
      setState(() {
        passwordErrorText = passwordField.validate(passwordController.text);
      });

      // Check if all fields are valid
      if (emailErrorText == null && passwordErrorText == null) {
        // All fields are valid, proceed with signup logic
        print('Login started');
        _handleLogin();
        print('Login finished');
        // ...
    }
  }

  Future<void> _handleLogin() async {
    String email = emailController.text;
    String password = passwordController.text;

    debugPrint('Email: ${email}, Password: ${password}');
    final userLoginAPI = getIt<ApiAuthNativeLogin>();
    final Map<String, dynamic> responseData =
    await userLoginAPI.loginUser(email, password);

    if (responseData.containsKey('login_success')) {
      final bool loginSuccess = responseData['login_success'];

      if (loginSuccess) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Icon(Icons.check_circle, color: Colors.green, size: 48),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Logged in successfully'),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        ).then((_) {
          // Close the dialog and return to the previous screen or route
          Navigator.pop(context);
          // Retrieve the passed arguments
          print('_handleLogin: before redirectRoute');

          print('_handleLogin redirectRoute ${widget.redirectRoute}');

          Navigator.pop(context);
          return;
          //Navigator.pushReplacementNamed(context, widget.redirectRoute ?? '/');
        });
      } else {
        // Handle unexpected response format
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade900,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Log In'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Card(
                elevation: 4.0, // Add elevation for a shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                  side: BorderSide(color: Colors.white, width: 2.0), // Border color and width
                ),
                color: Colors.deepPurple,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Log In ',
                            style: TextStyle(color: Colors.greenAccent,fontSize: 16),
                          ),
                          Icon(Icons.lock_person, color: Colors.greenAccent,)
                        ],
                      ),
                      EmailField(
                        controller: emailController,
                        hintText: 'Enter your email address',
                        labelText: 'Email',
                      ),
                      SizedBox(height: 10),
                      PasswordField(
                        controller: passwordController,
                        hintText: 'Enter your password',
                        labelText: 'Password',
                      ),

                      SizedBox(height: 20),
                      FloatingActionButton.extended(
                        heroTag: 'hero_5',
                        onPressed: _handleAuth,
                        label: Text(
                          'Log In',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                        icon: Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmailField extends BaseField {
  EmailField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
  }) : super(controller: controller, labelText: labelText, hintText: hintText);

  @override
  String? validate(String value) {
    // Basic email validation, you can customize this regex as needed
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  _EmailFieldState createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  String? emailErrorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      showCursor: true,
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.greenAccent, fontSize: 18),
      cursorColor: Colors.greenAccent,
      onFieldSubmitted: (value) {
        setState(() {
          emailErrorText = widget.validate(value);
        });
      },
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.white),
        focusColor: Colors.red,
        errorText: emailErrorText,
        labelStyle: TextStyle(color: Colors.greenAccent),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.greenAccent, // Replace with your desired color
            width: 2.0, // Adjust the width of the line
          ),
        ),
      ),
    );
  }
}

class PasswordField extends BaseField {
  PasswordField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
  }) : super(controller: controller, labelText: labelText, hintText: hintText);

  @override
  String? validate(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  String? passwordErrorText;
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                obscureText: _isPasswordHidden,
                controller: widget.controller,
                style: TextStyle(color: Colors.greenAccent, fontSize: 18),
                cursorColor: Colors.greenAccent,
                onChanged: (value) {
                  setState(() {
                    passwordErrorText = widget.validate(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.white),
                  focusColor: Colors.red,
                  errorText: passwordErrorText,
                  labelStyle: TextStyle(color: Colors.greenAccent),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.greenAccent, // Replace with your desired color
                      width: 2.0, // Adjust the width of the line
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  // Toggle the password visibility
                  _isPasswordHidden = !_isPasswordHidden;
                });
              },
              icon: Icon(
                _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UsernameField extends BaseField {
  UsernameField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
  }) : super(controller: controller, labelText: labelText, hintText: hintText);

  @override
  String? validate(String value) {
    if (value.isEmpty) {
      return 'Username is required';
    }
    final validCharacters = RegExp(r'^[a-zA-Z0-9._]+$'); // Only letters, numbers, periods, and underscores are allowed
    if (!validCharacters.hasMatch(value)) {
      return 'Username can only contain letters, numbers, periods, or underscores';
    }
    if (value.length < 5) {
      return 'Username must be at least 5 characters';
    }
    return null;
  }

  @override
  _UsernameFieldState createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<UsernameField> {
  String? usernameErrorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      showCursor: true,
      controller: widget.controller,
      style: TextStyle(color: Colors.greenAccent, fontSize: 18),
      cursorColor: Colors.greenAccent,
      onChanged: (value) {
        setState(() {
          usernameErrorText = widget.validate(value);
        });
      },
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.white),
        focusColor: Colors.red,
        errorText: usernameErrorText,
        labelStyle: TextStyle(color: Colors.greenAccent),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.greenAccent, // Replace with your desired color
            width: 2.0, // Adjust the width of the line
          ),
      ),
      ),
    );
  }
}




//For the validation fields:
abstract class BaseField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;

  BaseField({
    required this.controller,
    this.labelText,
    this.hintText,
  });

  String? validate(String value);
}
