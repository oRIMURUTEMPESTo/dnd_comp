// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharacterAdapter extends TypeAdapter<Character> {
  @override
  final int typeId = 1;

  @override
  Character read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Character(
      id: fields[0] as String,
      name: fields[1] as String,
      characterClass: fields[2] as String,
      level: fields[3] as int,
      race: fields[4] as String,
      background: fields[5] as String,
      alignment: fields[6] as String,
      strength: fields[7] as int,
      dexterity: fields[8] as int,
      constitution: fields[9] as int,
      intelligence: fields[10] as int,
      wisdom: fields[11] as int,
      charisma: fields[12] as int,
      campaignName: fields[13] as String,
      maxHp: fields[14] as int,
      currentHp: fields[15] as int,
      armorClass: fields[16] as int,
      speed: fields[17] as int,
      imagePath: fields[18] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Character obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.characterClass)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.race)
      ..writeByte(5)
      ..write(obj.background)
      ..writeByte(6)
      ..write(obj.alignment)
      ..writeByte(7)
      ..write(obj.strength)
      ..writeByte(8)
      ..write(obj.dexterity)
      ..writeByte(9)
      ..write(obj.constitution)
      ..writeByte(10)
      ..write(obj.intelligence)
      ..writeByte(11)
      ..write(obj.wisdom)
      ..writeByte(12)
      ..write(obj.charisma)
      ..writeByte(13)
      ..write(obj.campaignName)
      ..writeByte(14)
      ..write(obj.maxHp)
      ..writeByte(15)
      ..write(obj.currentHp)
      ..writeByte(16)
      ..write(obj.armorClass)
      ..writeByte(17)
      ..write(obj.speed)
      ..writeByte(18)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
