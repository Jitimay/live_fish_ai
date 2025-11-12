// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fish_catch.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FishCatchAdapter extends TypeAdapter<FishCatch> {
  @override
  final int typeId = 0;

  @override
  FishCatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FishCatch(
      id: fields[0] as String,
      species: fields[1] as String,
      length: fields[2] as double,
      confidence: fields[3] as double,
      timestamp: fields[4] as DateTime,
      isJuvenile: fields[5] as bool,
      latitude: fields[6] as double?,
      longitude: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, FishCatch obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.species)
      ..writeByte(2)
      ..write(obj.length)
      ..writeByte(3)
      ..write(obj.confidence)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.isJuvenile)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishCatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
