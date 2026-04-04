// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sos_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SOSEventAdapter extends TypeAdapter<SOSEvent> {
  @override
  final int typeId = 1;

  @override
  SOSEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SOSEvent(
      time: fields[0] as DateTime,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      contactsCount: fields[3] as int,
      primaryContact: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SOSEvent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.contactsCount)
      ..writeByte(4)
      ..write(obj.primaryContact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SOSEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
