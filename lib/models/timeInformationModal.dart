import 'package:hive/hive.dart';


part 'timeInformationModal.g.dart';

@HiveType(typeId: 3)
class Timeinformationmodal {

  @HiveField(0)
  String BST;

  @HiveField(1)
  String BET;

  @HiveField(2)
  String totalCustomer;

  @HiveField(3)
  String ? additionalInformation;

  Timeinformationmodal({
    required this.BST,
    required this.BET,
    required this.totalCustomer,
    this.additionalInformation
  });
}