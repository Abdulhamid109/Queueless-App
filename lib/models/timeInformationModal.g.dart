// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeInformationModal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeinformationmodalAdapter extends TypeAdapter<Timeinformationmodal> {
  @override
  final int typeId = 3;

  @override
  Timeinformationmodal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Timeinformationmodal(
      BST: fields[0] as String,
      BET: fields[1] as String,
      totalCustomer: fields[2] as String,
      additionalInformation: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Timeinformationmodal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.BST)
      ..writeByte(1)
      ..write(obj.BET)
      ..writeByte(2)
      ..write(obj.totalCustomer)
      ..writeByte(3)
      ..write(obj.additionalInformation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeinformationmodalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
