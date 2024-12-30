// Filename: exercise_display_screen.dart

import 'package:flutter/material.dart';
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
          : exercises.isEmpty
              ? Center(
                  child: Text(
                    'No exercises available',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchExercises,
                  child: ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
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
