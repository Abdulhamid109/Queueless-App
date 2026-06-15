// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkerInformationModal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkerinformationmodalAdapter
    extends TypeAdapter<Workerinformationmodal> {
  @override
  final int typeId = 1;

  @override
  Workerinformationmodal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workerinformationmodal(
      WorkerEmail: fields[1] as String,
      WorkerName: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Workerinformationmodal obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.WorkerName)
      ..writeByte(1)
      ..write(obj.WorkerEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkerinformationmodalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
