import 'package:hive/hive.dart';
import 'composition_tag.dart';

class CompositionTagAdapter extends TypeAdapter<CompositionTag> {
  @override
  final typeId = 3; // Ensure that this typeId is unique across your application

  @override
  CompositionTag read(BinaryReader reader) {
    var id = reader.readString();
    var tag = reader.readString();
    var createdAtTicks = reader.readInt();
    var createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtTicks);
    return CompositionTag(id: id, tag: tag, createdAt: createdAt);
  }

  @override
  void write(BinaryWriter writer, CompositionTag obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.tag);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
