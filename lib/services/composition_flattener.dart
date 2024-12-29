import '../models/audio.dart';
import '../models/composition.dart';
import '../models/composition_audio.dart';

class CompositionFlattener {
  List<CompositionAudio> flattenComposition(Composition rootComposition) {
    List<CompositionAudio> flattenedList = [];
    // Start with the root composition
    _flattenCompositionHelper(rootComposition, flattenedList, 1);
    return flattenedList;
  }

  void _flattenCompositionHelper(
      Composition composition,
      List<CompositionAudio> flattenedList,
      int parentRepetition) {
    for (CompositionAudio compAudio in composition.compositionAudios) {
      // Calculate total repetitions
      int totalRepetitions = compAudio.audioRepetition * parentRepetition;
      print('This is _flattenCompositionHelper');
      print('_flattenCompositionHelper compAudio.content ${compAudio.content}');
      print('compAudio.content: ${compAudio.content}');
      print('compAudio.content is Audio: ${(compAudio.content is Audio)}');
      print('compAudio.content is Composition: ${(compAudio.content is Composition)}');
      if (compAudio.content is Audio) {
        print('compAudio.content.clientAppAudioFilePath: ${compAudio.content.clientAppAudioFilePath}');
        for (int i = 0; i < totalRepetitions; i++) {
          // Add the audio file the number of times it should be repeated
          flattenedList.add(CompositionAudio(
              compositionAudioId: compAudio.compositionAudioId,
              content: compAudio.content,
              audioPosition: compAudio.audioPosition,
              audioRepetition: 1 // since we're handling repetition manually
          ));
        }
      } else if (compAudio.content is Composition) {
        print('_flattenCompositionHelper composition handling: compAudio.content: ${compAudio.content}');
        print('totalRepetitions ${totalRepetitions}');
        for (int i = 0; i < totalRepetitions; i++) {
          // Recursively flatten nested compositions
          print('totalRepetitions ${totalRepetitions}');
          _flattenCompositionHelper(
              compAudio.content as Composition, flattenedList, 1); // pass 1 as we've already calculated total repetitions
        }
      }
    }
  }
}
