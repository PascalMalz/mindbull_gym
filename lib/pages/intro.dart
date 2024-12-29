import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../widgets/rating_table.dart';
import 'goals.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  State<Intro> createState() => _State();
}

class _State extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          titleWidget: Text(
            "Intro",
            style: TextStyle(fontSize: 24),
          ),
          bodyWidget: Column(
            children: [
              Text(
                "Why do I need this app?",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350, // Set the desired width for the text box
                    height: 300, // Set the desired height for the text box
                    child: Text(
                        'This App is all about Affirmations in form of Sounds which will reconfigure your subconscious mind and so help you to: \n• Achieve your goals \n• Make you more relaxed\n• Help you to fall asleep\n• Enjoy the moment\n• And many more... \n\nAffirmations play a crucial role in shaping our beliefs and behaviors. This is an example for an Affirmation: \n"I deserve it to be happy because I wish the same to everyone else in my situation. I would never want someoen else to not be happy so I wish the same for me."\nBy repeating such positive statements, you can overwrite negative thought patterns and replace them with more empowering ones. Good vibes :)'),
                  ),
                  SizedBox(
                    width: 350, // Set the desired width for the video
                    height: 350, // Set the desired height for the video
                    child: _buildVideoWidget(),
                  ),

                ],
              ),
            ],
          ),
        ),


        PageViewModel(
          titleWidget: Text(""),
          bodyWidget: Column(
            children: [
              Text(
                "And how?",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Image.asset('assets/process.png'),
              ),
              SizedBox(
                width: 350, // Set the desired width for the text box
                height: 300, // Set the desired height for the text box
                child: Text(
                    'This App is all about Affirmations in form of Sounds which will reconfigure your subconscious mind and so help you to: \n• Achieve your goals \n• Make you more relaxed\n• Help you to fall asleep\n• Enjoy the moment\n• And many more... \n\nAffirmations play a crucial role in shaping our beliefs and behaviors. This is an example for an Affirmation: \n"I deserve it to be happy because I wish the same to everyone else in my situation. I would never want someoen else to not be happy so I wish the same for me."\nBy repeating such positive statements, you can overwrite negative thought patterns and replace them with more empowering ones. Good vibes :)'),
              ),
            ],
          ),
        ),
        PageViewModel(
          titleWidget: Text(""),
          bodyWidget: Column(
            children: [
              Text(
                "Set up your SECRET key",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Image.asset('assets/secure_lock.png'),
              ),
            ],
          ),
        ),
        PageViewModel(
          titleWidget: Text(""),
          bodyWidget: Column(
            children: [
              Text(
                "Rate your Weaknesses",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: RatingTable(),
              ),
            ],
          ),
        ),
        PageViewModel(
          titleWidget: Text(""),
          bodyWidget: Column(
            children: [
              Text(
                "Rate your Goals :)",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 1,
                child: RatingTable(),
              ),
            ],
          ),
        ),
      ],
      showSkipButton: false,
      showBackButton: true,
      showNextButton: true, // We will handle next buttons ourselves
      next: const Text("Next", style: TextStyle(fontWeight: FontWeight.w700)),
      back: const Text("Back", style: TextStyle(fontWeight: FontWeight.w700)),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w700)),
      onDone: () {
        Navigator.pop(context);
        /*Navigator.pushNamed(context, '/');*/
      },
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).colorScheme.secondary,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
    );
  }
}

Widget _buildVideoWidget() {
  final videoPlayerController = VideoPlayerController.asset('assets/flying_brain_with_cape_2.mp4');

  final chewieController = ChewieController(
    videoPlayerController: videoPlayerController,
    looping: true,
    autoPlay: true,
    showControls: false,
    // Other ChewieController configurations if needed
  );

  return Chewie(
    controller: chewieController,
  );
}
