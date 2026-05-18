import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// 3e6edc45-e7b7-4e4b-a390-a67ac480b416

class FlutterMapp extends StatelessWidget {
  const FlutterMapp({super.key});

  @override
  Widget build(BuildContext context) {
    // const styleUrl =
    //     "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png";
    // const apiKey = "3e6edc45-e7b7-4e4b-a390-a67ac480b416";
    final api_key = dotenv.get('API_URL');
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(51.509364, -0.128928),
        initialZoom: 9.2,
      ),
      children: [
        TileLayer(
          // 3e6edc45-e7b7-4e4b-a390-a67ac480b416
          urlTemplate: 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=$api_key',
          userAgentPackageName: 'com.example.queueless',
        ),

        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(51.509364, -0.128928),
              alignment: Alignment.centerLeft,
              width: 60,
              height: 60,
              child: Icon(Icons.location_pin, size: 60),
            ),
          ],
        ),
      ],
    );
  }
}
