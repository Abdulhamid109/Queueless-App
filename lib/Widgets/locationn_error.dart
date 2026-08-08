import 'package:flutter/material.dart';

class LocationnError extends StatefulWidget {
  final Widget screen;

  const LocationnError({super.key, required this.screen});

  @override
  State<LocationnError> createState() => _LocationnErrorState();
}

class _LocationnErrorState extends State<LocationnError> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_off_outlined,
                    size: 42,
                    color: Color(0xFF159447),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Location is turned off",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Queueless needs your location to find nearby "
                  "businesses and manage your queue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: Color(0xFF707070),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => widget.screen),
                      );
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Try Again",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF159447),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Please turn on location and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF8A8A8A)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
