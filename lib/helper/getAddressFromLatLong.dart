import 'package:geocoding/geocoding.dart';

Future<String> getAddressFromLatLong(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

    Placemark place = placemarks.first;
    print("-------------------All Address:$place-----------------------");

    String address =
        "${place.street}, "
        "${place.locality}, "
        "${place.country}";
    // widget.onAddressChange(address);
    print("Addresssssssssssssss : $address");
    return address;
  
}
