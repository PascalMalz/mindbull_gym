import 'package:hive/hive.dart';
import 'audio.dart';
import 'composition.dart';
import 'composition_audio.dart';

class CompositionAudioAdapter extends TypeAdapter<CompositionAudio> {
  @override
  final typeId = 1; // Ensure this is unique for each type

  @override
  CompositionAudio read(BinaryReader reader) {
    var id = reader.readString();
    var contentType = reader.readByte(); // 0 for AudioFile, 1 for Composition
    dynamic content;

    if (contentType == 0) {
      content = reader.read(); // Reading AudioFile, assuming AudioFileAdapter is registered
    } else if (contentType == 1) {
      content = reader.read(); // Reading Composition, assuming CompositionAdapter is registered
    }

    var audioPosition = reader.readInt();
    var audioRepetition = reader.readInt();
    return CompositionAudio(
      compositionAudioId: id,
      content: content,
      audioPosition: audioPosition,
      audioRepetition: audioRepetition,
    );
  }

  @override
  void write(BinaryWriter writer, CompositionAudio obj) {
    writer.writeString(obj.compositionAudioId);
    if (obj.content is Audio) {
      writer.writeByte(0); // Indicate that the content is an AudioFile
      writer.write(obj.content);
    } else if (obj.content is Composition) {
      writer.writeByte(1); // Indicate that the content is a Composition
      writer.write(obj.content);
    }
    writer.writeInt(obj.audioPosition);
    writer.writeInt(obj.audioRepetition);
  }
}
