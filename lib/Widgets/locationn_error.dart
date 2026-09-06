import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationnError extends StatefulWidget {
  final Widget screen;

  const LocationnError({
    super.key,
    required this.screen,
  });

  @override
  State<LocationnError> createState() => _LocationnErrorState();
}

class _LocationnErrorState extends State<LocationnError> {
  bool _isChecking = false;

  Future<void> _tryAgain() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      // Check whether device location is enabled.
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();

        if (mounted) {
          setState(() {
            _isChecking = false;
          });
        }

        return;
      }

      // Check location permission.
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Permission permanently denied.
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();

        if (mounted) {
          setState(() {
            _isChecking = false;
          });
        }

        return;
      }

      // We need background-capable permission for Queueless
      // location tracking.
      if (permission == LocationPermission.whileInUse) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget.screen,
          ),
        );

        return;
      }

      // Permission is still insufficient.
      if (mounted) {
        setState(() {
          _isChecking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please allow location access to continue.",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Location permission error: $e");

      if (mounted) {
        setState(() {
          _isChecking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Unable to access location. Please check your settings.",
            ),
          ),
        );
      }
    }
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

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
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
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
                  "Location access required",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Queueless needs location access to find nearby "
                  "businesses and track your journey to your queue.",
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
                    onPressed:
                        _isChecking ? null : _tryAgain,
                    icon: _isChecking
                        ? const SizedBox(
                            height: 19,
                            width: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isChecking
                          ? "Checking..."
                          : "Try Again",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF159447),
                      disabledBackgroundColor:
                          const Color(0xFF8BC9A5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _openLocationSettings,
                      child: const Text(
                        "Location Settings",
                        style: TextStyle(
                          color: Color(0xFF159447),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Text(
                      " • ",
                      style: TextStyle(
                        color: Color(0xFFAAAAAA),
                      ),
                    ),

                    TextButton(
                      onPressed: _openAppSettings,
                      child: const Text(
                        "App Settings",
                        style: TextStyle(
                          color: Color(0xFF159447),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                const Text(
                  "Location access is required for live queue tracking.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                
                SizedBox(height:10),
                const Text(
                  "Note: Location access should be 'Allow all the time' for background queue tracking",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 252, 3, 3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}