// Filename: lazy_loading_feed.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:self_code/api/api_feed_service.dart';
import '../notifier/scroll_position_notifier.dart';

class LazyLoadingFeed extends StatefulWidget {
  bool _dataLoaded = false;
  Future<List<dynamic>>? futurePosts;
  @override
  _LazyLoadingFeedState createState() => _LazyLoadingFeedState();
}

class _LazyLoadingFeedState extends State<LazyLoadingFeed> {

  @override
  bool get wantKeepAlive => true;

  List<dynamic> posts = [];


  final apiService = ApiFeedService();
  late final ScrollPositionNotifier scrollNotifier;
  late ScrollController _scrollController;

  @override
  void initState() {

    super.initState();

    _scrollController = ScrollController();
    scrollNotifier = Provider.of<ScrollPositionNotifier>(context, listen: false);
    print('scrollNotifier.position ${scrollNotifier.position}');
    print('LazyLoadingFeedState initState _dataLoaded1: ${widget._dataLoaded}');
    if (!widget._dataLoaded) {
    widget.futurePosts = apiService.fetchMorePosts();
    widget._dataLoaded = true;  // Mark the data as loaded after fetching it.
    }
    print('LazyLoadingFeedState initState _dataLoaded2: ${widget._dataLoaded}');
    _scrollController.addListener(() {
      scrollNotifier.position = _scrollController.offset;
      print('_LazyLoadingFeedState initState Scroll position stored! = ${_scrollController.offset}');

    });
    print('scrollNotifier.position2 ${scrollNotifier.position}');
    _loadAndSetScrollPosition();
    print('scrollNotifier.position3 ${scrollNotifier.position}');
  }

/*  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAndSetScrollPosition();
    print('_LazyLoadingFeedState didChangeDependencies Scroll position stored!');
    print('scrollNotifier.position4 ${scrollNotifier.position}');
  }*/


  void _loadAndSetScrollPosition() async{
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      //todo this needs to be more professional (not time based)
      await Future.delayed(Duration(milliseconds: 100));
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(scrollNotifier.position, duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
        print('Scroll position loaded = ${scrollNotifier.position}');
      }
    });
  }







  @override
  void dispose() {
    _scrollController.removeListener(() {
      scrollNotifier.position = _scrollController.offset;
    });
    _scrollController.dispose();
    super.dispose();
  }

  String formatDateString(String dateStr) {
    DateTime utcDateTime = DateTime.parse(dateStr);
    DateTime localDateTime = utcDateTime.toLocal();
    return DateFormat('y-MM-dd | HH:mm:ss').format(localDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade900,
      backgroundColor: Colors.black,
      body: FutureBuilder<List<dynamic>>(
        future: widget.futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Failed to load posts: ${snapshot.error}');
          } else if (snapshot.hasData) {
            posts.clear();
            posts.addAll(snapshot.data!);
            return ListView.builder(
              controller: _scrollController,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Opacity(
                            opacity: 0.5,
                            child: Image.asset('assets/background_sky.jpg'), // Replace this
                          ),
                        ),

                        Positioned(
                          top: 60,
                          left: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                          Text(
                                  posts[index]['content'] ?? 'Default Content',
                                  style: TextStyle(color: Colors.white),

                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                  "Erstellt: ${formatDateString(posts[index]['created_at'])}" ?? 'Default Content',
                                style: TextStyle(color: Colors.white),

                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 220,
                          left: 140,
                          child: Opacity(
                            opacity: 0.5,
                            child: IconButton(
                              iconSize: 80,
                              icon: Icon(Icons.play_circle, color: Colors.white,),
                              onPressed: () {
                                AudioPlayer audioPlayer = AudioPlayer();
                                //audioPlayer.play('https://example.com/song.mp3');
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0,top: 5),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage('assets/background_sky.jpg'),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  posts[index]['user']?['username'] ?? 'Default User',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 5),
                                                            SizedBox(width: 30),
                            ],
                          )

                        ),
                        // Add other Positioned widgets as per your design
                    // Adding a Positioned widget for the actions on the right side of your Container
                    Positioned(

                      bottom: 20,
                      right: 20, // To position it on the right side
                      child: Opacity(
                        opacity: 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              padding: EdgeInsets.all(0.0),
                              icon: Icon(Icons.star_rate_outlined, color: Colors.white, size: 40,),
                              onPressed: () {
                                // TODO: Handle the Save action
                              },
                            ),
                            Text(posts[index]['rating_average'].toString() ?? '', style: TextStyle(color: Colors.white),textAlign: TextAlign.center),
                            SizedBox(height: 8, width: 80,),
                            IconButton(
                              padding: EdgeInsets.all(0.0),
                              icon: Icon(Icons.save, color: Colors.white, size: 40,),
                              onPressed: () {
                                // TODO: Handle the Save action
                              },
                            ),
                            SizedBox(height: 8,),
                            IconButton(
                              padding: EdgeInsets.all(0.0),
                              icon: Icon(Icons.share, color: Colors.white, size: 40,),
                              onPressed: () {
                                // TODO: Handle the Share action
                              },
                            ),
                            SizedBox(height: 8,),
                            IconButton(
                              padding: EdgeInsets.all(0.0),
                              icon: Icon(Icons.comment, color: Colors.white, size: 40,),
                              onPressed: () {
                                // TODO: Handle the Comment action
                              },
                            ),
                            SizedBox(height: 8,),
                            IconButton(
                              padding: EdgeInsets.all(0.0),
                              icon: Icon(Icons.note_add, color: Colors.white, size: 40,),
                              onPressed: () {
                                // TODO: Handle the Use as Template action
                              },
                            ),
                            SizedBox(height: 8,),
                            IconButton(
                              padding: EdgeInsets.all(0.0),
                              icon: Icon(Icons.report_problem, color: Colors.white, size: 40,),
                              onPressed: () {
                                // TODO: Handle the Report action
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Text('No data');
          }
        },
      ),
    );
  }
}
