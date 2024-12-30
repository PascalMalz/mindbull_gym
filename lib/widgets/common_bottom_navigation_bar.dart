// What this code does:
// This Dart file defines a CommonWrapper widget that wraps its child with a Scaffold
// and a consistent BottomNavigationBar. The BottomNavigationBar has 6 items including a profile picture.
// It also includes methods for authorization checks and internal navigation logic.

// Filename: common_bottom_navigation_bar.dart
//todo when click on profile page the loginscreen forwards to /authorization, but this flow should be managed by commonwidget

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_code/pages/home_page.dart';
import '../main.dart';
import '../pages/audio_library.dart';
import '../pages/edit_view_your_library.dart';
import '../pages/library.dart';
import '../pages/log_screen.dart';
import '../pages/media_editor_page.dart';
import '../pages/new_home_screen.dart';
import '../pages/prepare_join_list.dart';
import '../pages/profile.dart';
import '../pages/record.dart';
import '../pages/view_hive_data.dart';
import '../provider/auth_provider.dart';
import '../provider/user_data_provider.dart';

class CommonBottomNavigationBar extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  CommonBottomNavigationBar({
    required this.child,
    required this.currentIndex,
  });

  @override
  _CommonBottomNavigationBarState createState() =>
      _CommonBottomNavigationBarState();
}

class _CommonBottomNavigationBarState extends State<CommonBottomNavigationBar> {
  int _selectedIndex;
  _CommonBottomNavigationBarState() : _selectedIndex = 0;
  @override
  void initState() {
    print('CommonBottomNavigationBar initializing');
    super.initState();
    _selectedIndex = widget.currentIndex;
    _pages[widget.currentIndex] = widget.child;
    _isPageInitialized[widget.currentIndex] = true;
  }

  // To keep track of which pages have been initialized
  List<bool> _isPageInitialized = [true, false, false, false, false, false];
  // Pages list; initialized with the first page
  List<Widget?> _pages = [
    HomeScreen(),
    null,
    null,
    null,
    null,
    null,
  ];

  Future<bool> checkAuthorization(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (await authProvider.isLoggedIn) {
      return true;
    } else {
      final result = await Navigator.pushNamed(
        context,
        '/authentication',
        arguments: {'redirectRoute': '/profile'},
      );

      bool didLogIn = result as bool? ?? false;
      if (await authProvider.isLoggedIn) {
        didLogIn = true;
      }
      return didLogIn;
    }
  }

  Future<void> _onItemTapped(int index) async {
    final userId =
        Provider.of<UserDataProvider>(context, listen: false).currentUser?.id;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool initialized = true;
    setState(() {
      if (!_isPageInitialized[index]) {
        // Initialize the page if it has not been initialized
        switch (index) {
          case 1:
            _pages[index] = MusicLibraryHomeScreen(); //LogScreen();
            break;
          case 2:
            _pages[index] = AudioRecorder();
            break;
          case 3:
            _pages[index] = AudioFileListScreen(
              title: '',
            );
            break;
          case 4:
            _pages[index] =
                AudioLibrary(); //ViewDataPage();//MediaEditorPage();
            break;
          case 5:
            // Initialize the profile page only if the user is authorized

            Future<void> handleProfilePage() async {
              bool isAuthorized = await checkAuthorization(context);
              print(
                  'CommonWrapper: _onItemTapped: isAuthorized = $isAuthorized');
              if (isAuthorized) {
                _pages[index] = ProfilePage(userId: userId);
              }
              if (await authProvider.isLoggedIn) {
                _pages[index] = ProfilePage(userId: userId);
              } else {}
              setState(() {});
            }
            initialized = false;
            handleProfilePage();
            _pages[index] =
                LoginPromptPage(onLoginPressed: () => _onItemTapped(5));

            break;
        }
        _isPageInitialized[index] = initialized;
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, _) {
        ImageProvider? _profileImage;
        final user = userDataProvider.currentUser;
        print(
            'CommonBottomNavigationBar userDataProvider.user.username: ${userDataProvider.currentUser?.username}');
        if (user != null && user.profilePictureUrl != null) {
          _profileImage = NetworkImage(user.profilePictureUrl!);
        } else {
          _profileImage = AssetImage('assets/default_profile_picture.png');
        }

        return Scaffold(
          body: _pages[_selectedIndex] ?? Container(),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black, // Color of the border
                width: 1.0, // Thickness of the border
              ),
              //borderRadius: BorderRadius.circular(15.0), // Radius of the border corners
            ),
            child: Container(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  onTap: _onItemTapped,
                  currentIndex: _selectedIndex,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.mic),
                      label: 'Record',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add_circle_outline),
                      label: 'Create',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.queue_music),
                      label: 'Library',
                    ),
                    BottomNavigationBarItem(
                      icon: CircleAvatar(
                        backgroundImage: _profileImage,
                        radius: 12,
                      ),
                      label: 'Profile',
                    ),
                  ],
                  unselectedItemColor: Colors.white,
                  selectedItemColor: Colors.deepPurple,
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Your existing widgets FirstPage, SecondPage, ThirdPage, FourthPage, FifthPage, and ProfilePage should be defined elsewhere.
class LoginPromptPage extends StatelessWidget {
  final Function onLoginPressed;

  // Constructor takes a function to be called when the login button is pressed
  LoginPromptPage({required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'You have to login to visit the profile page',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => onLoginPressed(), // Call the provided function
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
