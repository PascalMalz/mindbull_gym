import 'package:flutter/material.dart';


class PlayIconButton extends StatelessWidget {
  const PlayIconButton({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon:
        const Icon(Icons.play_circle_outline_sharp, size: 80.0,color: Colors.deepPurple),
        //const Icon(Icons.play_arrow),
        onPressed: () {});
  }
}