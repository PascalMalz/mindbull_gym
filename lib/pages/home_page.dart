import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:self_code/main.dart';

import '../api/api_auth_social_login_and_registration.dart';
import '../presenatation/my_flutter_app_icons.dart';
import '../provider/auth_provider.dart';
import '../provider/user_data_provider.dart';
import '../widgets/loginScreenWidget.dart';
import 'package:provider/provider.dart';


//void main() => runApp(const HomePage());

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authProvider = getIt.get<AuthProvider>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final socialAuth = getIt<ApiAuthSocialLoginAndRegistration>();
  late String username; // Declare username as an instance variable
  late String userId;
  @override
  void initState() {
    super.initState();
    //showIntro();
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    username = userDataProvider.currentUser?.username ?? 'N/A'; // 'N/A' is a fallback in case the username is null
    userId = userDataProvider.currentUser?.id ?? 'N/A';


  }


  bool hideIntro = false;
  bool endIntro = false;

/*
void showIntro() async {

  if(!hideIntro && !endIntro) {
    Navigator.pushNamed(context, '/intro');
  }

}*/



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        key: _scaffoldKey, // Add the scaffold key
        appBar: buildAppBar(context), // Add the app bar
        drawer: buildLeftBar(), // Add the sidebar
        endDrawer: buildRightBar(),
        body: Container(
          child: buildContent(context),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final username = userDataProvider.currentUser?.username ?? 'N/A';
    return AppBar(
      title: Text(username),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            _scaffoldKey.currentState!.openEndDrawer();
          },
        ),
      ],
    );
  }


  Drawer buildLeftBar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<UserDataProvider>(
            builder: (context, userDataProvider, child) {
              final username = userDataProvider.currentUser?.username ?? 'N/A';
              return DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/pascalmalz.jpg'),
                    ),
                    SizedBox(height: 10),
                    Text(username,
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              );
            },
          ),
              authProvider.isLoggedIn ?
              Builder(
                builder: (BuildContext context) {
                  return ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Log Out'),
                    onTap: () async {
                      if (await authProvider.logout()) {
                        // Close the drawer
                        Navigator.of(context).pop();

                        // Show the SnackBar after a brief delay to allow the drawer to close
                        Future.delayed(Duration(milliseconds: 300), () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logged out successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          setState(() {}); // Rebuild the drawer
                        });
                      }
                    },
                  );
                },
              )
              :
              Builder(
                builder: (BuildContext context) {
                  return ListTile(
                    leading: Icon(Icons.login),
                    title: Text('Log In'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(redirectRoute: '/'),
                        ),
                      );
                    },
                  );
                },
              )
            ],
      ),
    );
  }

  Drawer buildRightBar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  // You can replace this with your profile picture logic
                  backgroundImage: AssetImage('assets/pascalmalz.jpg'),
                ),
                SizedBox(height: 10),
                Text(
                  'PascalMalz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () {
              // Implement logout logic here
            },
          ),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background13.jpg'),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Container(
            color: Color.fromRGBO(0, 0, 0, 0.37), // Adjust the alpha (0.5) for desired transparency
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: GridView.count(
              crossAxisCount: 1,
              childAspectRatio: 2.93,
              crossAxisSpacing: 40.0,
              mainAxisSpacing: 30.0,
              children: [
                FunctionCard(
                  title: 'Start a program',
                  description: "Listen to composition of sounds / affirmations to: \n• Be more relaxed\n• Be more focused\n• Sleep better\n• Enjoy the moment",
                  icon: Icons.play_arrow,
                  onTap: () {
                    Navigator.pushNamed(context, '/start_a_program');
                  },
                ),
                FunctionCard(
                  title: 'Browse the public Library',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.library_add_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/library');
                  },
                ),
                FunctionCard(
                  title: 'Edit / view your library',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.library_music_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/edit_view_your_library');
                  },
                ),
                FunctionCard(
                  title: 'Create new program / mix',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.queue_music,
                  onTap: () {
                    Navigator.pushNamed(context, '/join_list');
                  },
                ),
                FunctionCard(
                  title: 'Take a quick record',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.mic,
                  onTap: () {
                    Navigator.pushNamed(context, '/record');
                  },
                ),
                FunctionCard(
                  title: 'Add more functionalities',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.add_shopping_cart,
                  onTap: () {
                    Navigator.pushNamed(context, '/record');
                  },
                ),
                FunctionCard(
                  title: 'View JSON',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.file_copy_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/view_json');
                  },
                ),
                FunctionCard(
                  title: 'Playlist',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.file_copy_outlined,
                  onTap: () {
                    Navigator.pushNamed(context, '/playlist');
                  },
                ),
                FunctionCard(
                  title: 'Reels',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.mediation_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, '/reels');
                  },
                ),
                FunctionCard(
                  title: 'Intro',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.school,
                  onTap: () {
                    Navigator.pushNamed(context, '/intro');
                  },
                ),
                FunctionCard(
                  title: 'Upload files',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.cloud_upload,
                  onTap: () {
                    Navigator.pushNamed(context, '/upload_files');
                  },
                ),
                FunctionCard(
                  title: 'Your Profile',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/profile',
                      arguments: {'userId': userId}, // Replace with the actual user ID
                    );
                  },
                ),
                FunctionCard(
                  title: 'Not your Profile - baddii',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/profile',
                      arguments: {'userId': 'baddii'}, // Replace with the actual user ID
                    );
                  },
                ),
                FunctionCard(
                  title: 'Authentication',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.lock,
                  onTap: () {
                    Navigator.pushNamed(context, '/authentication');
                  },
                ),
                FunctionCard(
                  title: 'Logging',
                  description: "Listen to composition of sounds and affirmations to: \n•Be more relaxed\n•Be more focused•\nSleep better\•Enjoy the moment",
                  icon: Icons.lock,
                  onTap: () {
                    Navigator.pushNamed(context, '/log');
                  },                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}

class FunctionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const FunctionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Card(
          elevation: 0, // Remove the default card shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Set the border radius to 0 for squared corners
          ),
          margin: EdgeInsets.zero, // Remove the default card margin
          color: Colors.white.withOpacity(0.2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 20),
              Positioned(
                left: 20,
                child: Container(
                  height: 80,
                  width: 80, // Adjust the width as needed for your icon size
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0x041D2A).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
               Positioned(
                 top: 30,
                 left: 120,
                 child: Container(
                   height: 40,
                   width: 600,
                   child: Text(
                     title,
                     style: const TextStyle(
                       color: Colors.white,
                       fontSize: 22,
                     ),
                     textAlign: TextAlign.left,
                     overflow: TextOverflow.fade, // Apply fade overflow behavior
                     maxLines: 1, // Set the maximum number of lines
                   ),
                 ),
               ),
              Positioned(
                top: 60,
                left: 120,
                child: Container(
                  height: 100,
                  width: 300,
                  child: Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.fade, // Apply fade overflow behavior
                    maxLines: 10, // Set the maximum number of lines
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
