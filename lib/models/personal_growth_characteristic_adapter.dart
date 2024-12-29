import 'package:hive/hive.dart';
import 'package:self_code/models/personal_growth_characteristic.dart';

import 'characteristic_rating.dart';

class PersonalGrowthCharacteristicAdapter extends TypeAdapter<PersonalGrowthCharacteristic> {
  @override
  final typeId = 5;  // Ensure that typeId is unique for each TypeAdapter

  @override
  PersonalGrowthCharacteristic read(BinaryReader reader) {
    // Adjust according to your fields
    return PersonalGrowthCharacteristic(
      category: reader.readString(),
      name: reader.readString(),
      description: reader.readString(),
      rating: CharacteristicRating(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, PersonalGrowthCharacteristic obj) {
    // Adjust according to your fields
    writer.writeString(obj.category ?? '');
    writer.writeString(obj.name ?? '');
    writer.writeString(obj.description ?? '');
    writer.writeInt(obj.rating.value);
  }
}
