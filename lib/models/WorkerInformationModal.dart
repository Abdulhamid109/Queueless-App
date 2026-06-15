import 'package:hive/hive.dart';

part 'WorkerInformationModal.g.dart';

@HiveType(typeId: 1)
class Workerinformationmodal {
  @HiveField(0)
  String WorkerName;

  @HiveField(1)
  String WorkerEmail;

  Workerinformationmodal({required this.WorkerEmail, required this.WorkerName});
}
