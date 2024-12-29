import 'package:uuid/uuid.dart';
import 'composition.dart';
import 'audio.dart';

class CompositionAudio {
  final String compositionAudioId;
  final dynamic content; // Can be either AudioFile or Composition
  int audioPosition;
  int audioRepetition;

  CompositionAudio({
    String? compositionAudioId,
    required this.content,
    required this.audioPosition,
    required this.audioRepetition,
  }) : compositionAudioId = compositionAudioId ?? const Uuid().v4();

  factory CompositionAudio.fromJson(Map<String, dynamic> json) {
    print('CompositionAudio.fromJson: fine before until here');
    var contentJson = json['content'];
    var contentType = json['content_type']; // Assuming 'type' field indicates whether it's an AudioFile or Composition
    print('contentType: $contentType');
    print('CompositionAudio.fromJson: fine until here contentJson: $contentJson');
    dynamic content;
    if (contentType == 'audio_file') {
      content = Audio.fromJson(contentJson);
    } else if (contentType == 'composition') {
      content = Composition.fromJson(contentJson);
    }
    print('CompositionAudio.fromJson: fine until after here');

    // Safely parse audioPosition and audioRepetition as integers
    var audioPosition = json['audio_position'] != null ? int.tryParse(json['audio_position'].toString()) ?? 0 : 0;
    var audioRepetition = json['audio_repetition'] != null ? int.tryParse(json['audio_repetition'].toString()) ?? 0 : 1;

    return CompositionAudio(
      compositionAudioId: json['composition_audio_id'],
      content: content,
      audioPosition: audioPosition,
      audioRepetition: audioRepetition,
    );
  }

  Map<String, dynamic> toJson() {
    var contentJson;
    if (content is Audio) {
      contentJson = (content as Audio).toJson();
      contentJson['type'] = 'audio_file'; // Add a 'type' field to indicate the content type
    } else if (content is Composition) {
      contentJson = (content as Composition).toJson();
      contentJson['type'] = 'composition'; // Add a 'type' field to indicate the content type
    }

    return {
      'composition_audio_id': compositionAudioId,
      'content_type': content is Audio ? 'audio_file' : 'composition',
      'content': contentJson,
      'audio_position': audioPosition,
      'audio_repetition': audioRepetition,
    };
  }
}