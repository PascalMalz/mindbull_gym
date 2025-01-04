// Filename: exercise_display_screen.dart

import 'package:flutter/material.dart';
import 'package:self_code/pages/post/full_screen_post_view.dart';
import 'package:self_code/pages/post/post_screen_composition.dart';
import 'package:self_code/pages/post/posts_audio_image_display_screen.dart';
import '../api/api_exercise_service.dart';
import '../models/exercise.dart';
import '../widgets/exercise_card.dart';

class ExerciseDisplayScreen extends StatefulWidget {
  final bool autoplayEnabled;
  final String exerciseType;

  ExerciseDisplayScreen({
    Key? key,
    required this.autoplayEnabled,
    required this.exerciseType,
  }) : super(key: key);

  @override
  _ExerciseDisplayScreenState createState() => _ExerciseDisplayScreenState();
}

class _ExerciseDisplayScreenState extends State<ExerciseDisplayScreen> {
  late List<Exercise> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  @override
  void didUpdateWidget(covariant ExerciseDisplayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseType != widget.exerciseType) {
      _fetchExercises();
    }
  }

  Future<void> _fetchExercises() async {
    setState(() {
      isLoading = true;
    });

    ApiExerciseService apiExerciseService = ApiExerciseService();

    try {
      exercises = await apiExerciseService.fetchExercises(
        exerciseType: widget.exerciseType,
      );
    } catch (e) {
      print('Error fetching exercises: $e');
      exercises = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchExercises,
              child: ListView.builder(
                itemCount: exercises.length + 2, // Add one for the button
                itemBuilder: (context, index) {
                  if (index == exercises.length) {
                    // Render the button as the last item in the list
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Add Exclusive Exercises"),
                        onPressed: () {
                          // Handle adding exclusive exercise logic
                          print("Add Exclusive Exercise clicked");
                        },
                      ),
                    );
                  }
                  if (index == exercises.length + 1) {
                    // Render the button as the last item in the list
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Add Community Material"),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    PostsAudioImageDisplayScreen(
                                        autoplayEnabled: false)),
                          );
                          // Handle adding exclusive exercise logic
                          print("Add Community Material");
                        },
                      ),
                    );
                  }
                  // Render exercise cards
                  return ExerciseCard(
                    exercise: exercises[index],
                    autoplayEnabled: widget.autoplayEnabled,
                  );
                },
              ),
            ),
    );
  }
}
