// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spell_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpellAdapter extends TypeAdapter<Spell> {
  @override
  final int typeId = 0;

  @override
  Spell read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Spell(
      id: fields[0] as String,
      name: fields[1] as String,
      level: fields[2] as int,
      school: fields[3] as String,
      castingTime: fields[4] as String,
      range: fields[5] as String,
      components: fields[6] as String,
      duration: fields[7] as String,
      description: fields[8] as String,
      isRitual: fields[9] as bool,
      isConcentration: fields[10] as bool,
      higherLevel: fields[11] as String,
      damageAtSlotLevel: (fields[12] as Map).cast<String, String>(),
      classes: (fields[13] as List).cast<String>(),
      damageAtCharacterLevel: (fields[14] as Map).cast<String, String>(),
      source: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Spell obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.school)
      ..writeByte(4)
      ..write(obj.castingTime)
      ..writeByte(5)
      ..write(obj.range)
      ..writeByte(6)
      ..write(obj.components)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.isRitual)
      ..writeByte(10)
      ..write(obj.isConcentration)
      ..writeByte(11)
      ..write(obj.higherLevel)
      ..writeByte(12)
      ..write(obj.damageAtSlotLevel)
      ..writeByte(13)
      ..write(obj.classes)
      ..writeByte(14)
      ..write(obj.damageAtCharacterLevel)
      ..writeByte(15)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpellAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
