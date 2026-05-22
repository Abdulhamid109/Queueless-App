import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class FlutterMapp extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Function(String,double,double) onAddressChange;

  const FlutterMapp({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onAddressChange,
  });

  @override
  State<FlutterMapp> createState() => _FlutterMappState();
}

class _FlutterMappState extends State<FlutterMapp> {
  late LatLng selectedLocation;

  String address = "Fetching address...";
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();

    selectedLocation = LatLng(widget.latitude, widget.longitude);

    getAddress(widget.latitude, widget.longitude);
  }

  Future<void> getAddress(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      Placemark place = placemarks.first;
      print("-------------------All Address:$place-----------------------");
      setState(() {
        address =
            "${place.street}, "
            "${place.locality}, "
            "${place.country}";
      });
      widget.onAddressChange(address,lat,lon);
    } catch (e) {
      setState(() {
        address = "Address not found";
      });
    }
  }

  @override
  void didUpdateWidget(FlutterMapp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      final newLocation = LatLng(widget.latitude, widget.longitude);
      setState(() {
        selectedLocation = newLocation;
      });
      _mapController.move(newLocation, 14); // ← re-centers the map
      getAddress(widget.latitude, widget.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.get('API_URL');

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: selectedLocation,
                initialZoom: 14,

                onTap: (tapPosition, point) async {
                  setState(() {
                    selectedLocation = point;
                  });

                  await getAddress(point.latitude, point.longitude);
                },
              ),

              children: [
                TileLayer(
                  urlTemplate:
                      'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$apiKey',

                  userAgentPackageName: 'com.example.queueless',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation,

                      width: 60,
                      height: 60,

                      child: const Icon(
                        Icons.location_pin,
                        size: 60,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            child: Text(address, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
