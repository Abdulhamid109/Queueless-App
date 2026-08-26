import 'package:geolocator/geolocator.dart';

Future<bool> requestLocationPermission() async {
  // 1. Check whether device location is enabled
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    return false;
  }

  // 2. Check current permission
  LocationPermission permission = await Geolocator.checkPermission();

  // 3. Request permission if denied
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return false;
    }
  }

  // 4. Permanently denied
  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openAppSettings();
    return false;
  }

  // 5. For your use case, background permission is important
  if (permission == LocationPermission.whileInUse) {
    permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.always) {
      return false;
    }
  }

  return permission == LocationPermission.always;
}