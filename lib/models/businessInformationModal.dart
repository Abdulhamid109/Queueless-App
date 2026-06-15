import 'package:hive/hive.dart';

part 'businessInformationModal.g.dart';

@HiveType(typeId: 0)
class Businessinformationmodal {

  @HiveField(0)
  String businessName;

  @HiveField(1)
  String businessAddress;

  @HiveField(2)
  String businessCategory;

  @HiveField(3)
  String country;

  @HiveField(4)
  String state;

  @HiveField(5)
  String city;

  @HiveField(6)
  String pinCode;

  @HiveField(7)
  String website;

  @HiveField(8)
  double latitude;

  @HiveField(9)
  double longitude;

  Businessinformationmodal({
    required this.businessName,
    required this.businessAddress,
    required this.businessCategory,
    required this.country,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.website,
    required this.latitude,
    required this.longitude,
  });
}