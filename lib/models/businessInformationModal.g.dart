// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'businessInformationModal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessinformationmodalAdapter
    extends TypeAdapter<Businessinformationmodal> {
  @override
  final int typeId = 0;

  @override
  Businessinformationmodal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Businessinformationmodal(
      businessName: fields[0] as String,
      businessAddress: fields[1] as String,
      businessCategory: fields[2] as String,
      country: fields[3] as String,
      state: fields[4] as String,
      city: fields[5] as String,
      pinCode: fields[6] as String,
      website: fields[7] as String,
      latitude: fields[8] as double,
      longitude: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Businessinformationmodal obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.businessName)
      ..writeByte(1)
      ..write(obj.businessAddress)
      ..writeByte(2)
      ..write(obj.businessCategory)
      ..writeByte(3)
      ..write(obj.country)
      ..writeByte(4)
      ..write(obj.state)
      ..writeByte(5)
      ..write(obj.city)
      ..writeByte(6)
      ..write(obj.pinCode)
      ..writeByte(7)
      ..write(obj.website)
      ..writeByte(8)
      ..write(obj.latitude)
      ..writeByte(9)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessinformationmodalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
