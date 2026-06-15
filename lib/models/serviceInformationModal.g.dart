// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serviceInformationModal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceinformationmodalAdapter
    extends TypeAdapter<Serviceinformationmodal> {
  @override
  final int typeId = 2;

  @override
  Serviceinformationmodal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Serviceinformationmodal(
      serviceName: fields[0] as String,
      serviceDuration: fields[1] as String,
      serviceCharge: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Serviceinformationmodal obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.serviceName)
      ..writeByte(1)
      ..write(obj.serviceDuration)
      ..writeByte(2)
      ..write(obj.serviceCharge);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceinformationmodalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
