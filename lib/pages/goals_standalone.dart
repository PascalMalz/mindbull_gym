import 'package:flutter/material.dart';

import 'goals.dart';

class GoalsStandalone extends StatefulWidget {
  const GoalsStandalone({super.key});

  @override
  State<GoalsStandalone> createState() => _GoalsStandaloneState();


}

class _GoalsStandaloneState extends State<GoalsStandalone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Personal Growth Characteristics'),

    ),
  body: RatingTable(),
    );

  }
}
