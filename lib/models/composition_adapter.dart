import 'package:hive/hive.dart';
import 'composition.dart';
import 'composition_audio.dart';
import 'composition_tag.dart';


class CompositionAdapter extends TypeAdapter<Composition> {
  @override
  final typeId = 0; // Ensure this ID is unique among all the adapters you have.

  @override
  Composition read(BinaryReader reader) {
    var id = reader.readString();
    var title = reader.readString();
    var description = reader.readString();
    var createdAt = DateTime.parse(reader.readString());
    var updatedAt = DateTime.parse(reader.readString());
    var compositionAudios = reader.readList().cast<CompositionAudio>();
    var compositionTags = reader.readList().cast<CompositionTag>();
    return Composition(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      compositionAudios: compositionAudios,
      compositionTags: compositionTags,
    );
  }

  @override
  void write(BinaryWriter writer, Composition obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.createdAt!.toIso8601String());
    writer.writeString(obj.updatedAt!.toIso8601String());
    writer.writeList(obj.compositionAudios);
    writer.writeList(obj.compositionTags);
  }
}