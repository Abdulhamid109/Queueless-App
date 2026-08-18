import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Fluttermapdistance extends StatefulWidget {
  final double userlatitude;
  final double userlongitude;
  final double businesslatitude;
  final double businesslongitude;

  const Fluttermapdistance({
    super.key,
    required this.userlatitude,
    required this.userlongitude,
    required this.businesslatitude,
    required this.businesslongitude,
  });

  @override
  State<Fluttermapdistance> createState() => _FluttermapdistanceState();
}

class _FluttermapdistanceState extends State<Fluttermapdistance> {
  late LatLng userLocation;
  late LatLng businessLocation;

  final Color primaryGreen = const Color(0xFF159447);
  final Color darkText = const Color(0xFF171717);
  final Color secondaryText = const Color(0xFF777777);

  final MapController _mapController = MapController();

  double _distanceKm = 0;

  @override
  void initState() {
    super.initState();

    // User location
    userLocation = LatLng(widget.userlatitude, widget.userlongitude);

    // Business location
    businessLocation = LatLng(
      widget.businesslatitude,
      widget.businesslongitude,
    );

    // Calculate straight-line distance
    _distanceKm = const Distance().as(
      LengthUnit.Kilometer,
      userLocation,
      businessLocation,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fitBounds();
      }
    });
  }

  void _fitBounds() {
    final bounds = LatLngBounds.fromPoints([userLocation, businessLocation]);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(60, 100, 60, 160),
      ),
    );
  }

  Widget _buildPin({required IconData icon, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 18),
        ),

        // Small pointer below the pin
        CustomPaint(
          size: const Size(10, 6),
          painter: _TrianglePainter(color: color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.get('API_URL');

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,

            options: MapOptions(initialCenter: userLocation, initialZoom: 18),

            children: [
              TileLayer(
                urlTemplate:
                    'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$apiKey',
                userAgentPackageName: 'com.example.queueless',
              ),

              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [userLocation, businessLocation],
                    strokeWidth: 8,
                    color: Colors.black.withOpacity(0.12),
                  ),

                  Polyline(
                    points: [userLocation, businessLocation],
                    strokeWidth: 4.5,
                    color: primaryGreen,
                    pattern: StrokePattern.dashed(segments: [12, 8]),
                  ),
                ],
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation,
                    width: 46,
                    height: 56,
                    alignment: Alignment.topCenter,
                    child: _buildPin(
                      icon: Icons.my_location_rounded,
                      color: Colors.blue,
                    ),
                  ),

                  Marker(
                    point: businessLocation,
                    width: 46,
                    height: 56,
                    alignment: Alignment.topCenter,
                    child: _buildPin(
                      icon: Icons.storefront_rounded,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Icon(
                      Icons.route_rounded,
                      color: primaryGreen,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Direct Distance to business',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: secondaryText,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '${_distanceKm.toStringAsFixed(_distanceKm < 1 ? 2 : 1)} km',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: _fitBounds,

                    icon: Icon(
                      Icons.center_focus_strong_rounded,
                      color: primaryGreen,
                    ),

                    tooltip: 'Recenter',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;

    // Explicitly use dart:ui Path
    final ui.Path path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
