// What this code does:
// This code creates a screen with a top menu, a horizontal list of profile pictures, a vertical list of music cards,
// and a bottom navigation menu with five icons.

// Filename: home_screen.dart
//todo when I go back to home the wrong menu icon is highlighted.
//todo dont always load the feed when it was already fetched from API...
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marquee/marquee.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:self_code/pages/post/post_screen_composition.dart';
import 'package:self_code/pages/post/posts_audio_image_display_screen.dart';
import 'package:self_code/widgets/common_bottom_navigation_bar.dart';

import '../provider/auth_provider.dart';
import '../provider/user_data_provider.dart';
import '../widgets/lazy_loading_feed.dart';
import 'post/generic_post_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();

  }
  ImageProvider? _profileImage;
  bool _autoplayEnabled = false;




  AppBar buildAppBar(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final username = userDataProvider.currentUser?.username ?? 'Not Logged In';

    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.deepPurple),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_alt_outlined,color: Colors.deepPurple,),
            onPressed: () {
            },
          ),
          // Expanded widget allows the title text to take the remaining space and center itself.
          Expanded(
            child: Text(
              'Explore Mindset Compositions',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
      elevation: 0,
    );
  }
  @override
  Widget build(BuildContext context) {
    return CommonBottomNavigationBar(
      currentIndex: 0,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: buildAppBar(context), // AppBar remains fixed at top
        endDrawer: buildRightBar(),
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              // The top menu and profile list as SliverAppBar
              backgroundColor: Colors.white,
              pinned: false, // Set to true if you want the AppBar to remain visible when scrolled
              expandedHeight: 100.0, // Adjust height accordingly
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Stack(children: [
                      Container(color: Colors.white,width: double.infinity,height: 91,),
                      Column(children: [
                        Container(
                          color: Colors.white,
                          height: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CompositionPostPage()),
                                  );
                                },
                                child: Container(
                                  width: 80,
                                  height: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 8), // Adjust padding as needed
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, // Use the minimum space that's needed by children
                                    mainAxisAlignment: MainAxisAlignment.center, // Center the items in the row
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 1), // Space between text and icon, adjust as needed
                                      Text(
                                        'Post',
                                        style: TextStyle(color: Colors.white),
                                      ),

                                    ],
                                  ),
                                ),
                              ),

                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: CircleAvatar(
                                        //backgroundImage: NetworkImage('https://example.com/image$index.jpg'),
                                        radius: 25,
                                      ),
                                    );
                                  },
                                ),
                              ),


                            ],
                          ),
                        ),
                        Container(height: 5,color: Colors.white,),
                        // Profile list
                        Container(
                          color: Colors.white,
                          height: 36,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(width: 2,),

                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(height: 36,width: 128,

                                      decoration: BoxDecoration(color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),),),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      height:34,
                                      width: 124,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),         child:
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => CompositionPostPage()),
                                          );
                                        },
                                        child: Text('Affirmations', style: TextStyle(fontSize: 18),),
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                      ),
                                    ),
                                    ),
                                  ]
                              ),
                              SizedBox(width: 2,),
                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(height: 36,width: 128,

                                      decoration: BoxDecoration(color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),),),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      height:34,
                                      width: 124,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),         child:
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => CompositionPostPage()),
                                          );
                                        },
                                        child: Text('Mixed Content', style: TextStyle(fontSize: 18),),
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                      ),
                                    ),
                                    ),
                                  ]
                              ),
                              SizedBox(width: 2,),
                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(height: 36,width: 128,

                                      decoration: BoxDecoration(color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),),),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      height:34,
                                      width: 124,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),         child:
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => CompositionPostPage()),
                                          );
                                        },
                                        child: Text('Single Audios', style: TextStyle(fontSize: 18),),
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                      ),
                                    ),
                                    ),
                                  ]
                              ),
                            ],
                          ),
                        ),
                      ],),

                    ],),

                    Container(height: 9, color: Colors.black,),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(height:400, child: PostsAudioImageDisplayScreen(autoplayEnabled: _autoplayEnabled)),
            ),
          ],
        ),
      ),
    );
  }
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
          leading: Icon(Icons.auto_graph,),
          title: Text('Goals'),
          onTap: () {
            // Implement logout logic here
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            // Implement logout logic here
          },
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

