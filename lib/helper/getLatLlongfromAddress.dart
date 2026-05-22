import 'package:geocoding/geocoding.dart';
// 
Future <Map<String,double>> getLatLongfromAddress (String location)async{
  List<Location> locations = await locationFromAddress(location);
  print("All Possible Locations........................$locations[0][0]");
  return {
    "lat":locations[0].latitude,
    'long':locations[0].longitude
  };
}