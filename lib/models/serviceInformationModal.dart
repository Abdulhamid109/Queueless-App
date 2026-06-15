import 'package:hive/hive.dart';


part 'serviceInformationModal.g.dart';


@HiveType(typeId: 2)
class Serviceinformationmodal {

  @HiveField(0)
  String serviceName;

  @HiveField(1)
  String serviceDuration;

  @HiveField(2)
  String serviceCharge;


  Serviceinformationmodal({
    required this.serviceName,
    required this.serviceDuration,
    required this.serviceCharge
  });
}