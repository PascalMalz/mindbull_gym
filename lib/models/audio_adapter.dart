import 'package:hive/hive.dart';
import 'audio.dart';

class AudioFileAdapter extends TypeAdapter<Audio> {
  @override
  final typeId = 2; // Ensure this is unique for each type

  @override
  Audio read(BinaryReader reader) {
    var id = reader.readString();
    var title = reader.readString();
    var clientAppAudioFilePath = reader.readString();
    var description = reader.readString();
    var duration = reader.readInt();
    var tags = reader.read().cast<String>(); // Assuming tags is a List<String>
    return Audio(
      id: id,
      title: title,
      clientAppAudioFilePath: clientAppAudioFilePath,
      description: description,
      duration: duration,
      tags: tags,
    );
  }

  @override
  void write(BinaryWriter writer, Audio obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.clientAppAudioFilePath);
    writer.writeString(obj.description);
    writer.writeInt(obj.duration);
    writer.write(obj.tags);
  }
}
