import 'dart:async';
import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/RequestLocationPermission.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// LocationTrackingService
//
// Owns the location StreamSubscription independently of any widget's
// lifecycle. Previously this subscription lived inside
// _NotificationScreenState and was cancelled in that State's dispose(),
// which meant navigating away from NotificationScreen (e.g. to the home
// screen) silently killed tracking. This singleton is not tied to any
// widget, so it keeps running across navigation until stop() is called
// explicitly.
// ============================================================================
class LocationTrackingService {
  LocationTrackingService._();
  static final LocationTrackingService instance = LocationTrackingService._();

  StreamSubscription<Position>? _subscription;

  bool get isTracking => _subscription != null;

  /// Returns true if tracking started successfully, false if location
  /// permission was denied.
  Future<bool> start() async {
    final isLocationEnabled = await requestLocationPermission();
    if (!isLocationEnabled) return false;

    // Cancel any previous stream before starting a new one, in case
    // start() is called again while already tracking.
    await _subscription?.cancel();

    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
      intervalDuration: const Duration(seconds: 5),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: "Queueless",
        notificationText: "Tracking your location while you're on your way.",
        enableWakeLock: true,
        setOngoing: true,
      ),
    );

    _subscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      debugPrint(
        "LiveLatitude ${position.latitude} - LiveLongitude ${position.longitude}",
      );
      _sendLocationToBackend(position.latitude, position.longitude);
    });

    return true;
  }

  /// Call this once the customer's slot is resolved (arrived, expired,
  /// or marked "not coming") — nothing calls this automatically.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _sendLocationToBackend(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedData = JwtDecoder.decode(token!);
      final uid = decodedData["uid"];

      await http.post(
        Uri.parse("$BaseUrl/customer/getLiveLocation/$uid"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );
      // Note: the original MaterialBanner UI feedback lived here, but a
      // singleton service must not hold a BuildContext/ScaffoldMessenger
      // (it can go stale or crash once the originating screen is gone).
      // That feedback is now a one-shot toast fired at the call site in
      // the "Coming" button's onPressed below, right after start() succeeds.
    } catch (e) {
      print("Error occured while updating the live locations => $e");
    }
  }
}

// ============================================================================
// NotificationScreen
// ============================================================================
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List allNotifications = [];
  Timer? _expiryTicker;

  final Color primaryGreen = const Color(0xFF159447);
  final Color lightGreen = const Color(0xFFEAF7EF);
  final Color darkText = const Color(0xFF171717);
  final Color secondaryText = const Color(0xFF777777);

  static const Duration _confirmationWindow = Duration(minutes: 15);

  Future getFiredNotifications() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      final token = preferences.getString("token");

      final decodedToken = JwtDecoder.decode(token!);

      final uid = decodedToken["uid"];

      final response = await http.get(
        Uri.parse("$BaseUrl/customer/getNotifications/$uid"),
        headers: {"Content-Type": 'application/json'},
      );

      if (response.statusCode == 200) {
        final respbody = jsonDecode(response.body);

        setState(() {
          allNotifications = respbody["data"];
        });
      }

      if (response.statusCode != 200) {
        CherryToast.error(
          title: const Text("Something went wrong"),
        ).show(context);

        throw Exception("Error => ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("error => $e");
    }
  }

  Future updateAckStatus(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse("$BaseUrl/customer/updateAckStatus/$notificationId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"status": "comming"}),
      );

      if (response.statusCode == 200) {
        CherryToast.success(
          title: const Text("Your Slot has been confirmed kindly reach fast!"),
        ).show(context);

        setState(() {
          final target = allNotifications.firstWhere(
            (n) => n["_id"] == notificationId,
            orElse: () => null,
          );

          if (target != null) {
            target["ackStatus"] = "comming";
          }
        });
      }

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        CherryToast.error(
          title: Text(body["error"] ?? "Something went wrong! This confirmation window may have expired."),
        ).show(context);

        throw Exception("Error => ${response.statusCode} -- ${response.body}");
      }
    } catch (e) {
      print("Error => $e");
    }
  }

  Future updateNegAckStatus(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse("$BaseUrl/customer/updateAckStatus/$notificationId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"status": "notcomming"}),
      );

      if (response.statusCode == 200) {
        CherryToast.info(
          title: const Text("Your Slot have been discarded!"),
        ).show(context);

        setState(() {
          final target = allNotifications.firstWhere(
            (n) => n["_id"] == notificationId,
            orElse: () => null,
          );

          if (target != null) {
            target["ackStatus"] = "notcomming";
          }
        });
      }

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        CherryToast.error(
          title: Text(body["error"] ?? "Something went wrong!"),
        ).show(context);

        throw Exception("Error => ${response.statusCode} -- ${response.body}");
      }
    } catch (e) {
      print("Error => $e");
    }
  }

  String _formatCreatedAt(dynamic rawDate) {
    if (rawDate == null) return "";

    try {
      final parsed = DateTime.parse(rawDate.toString()).toLocal();

      return DateFormat("dd MMM, hh:mm a").format(parsed);
    } catch (e) {
      return "";
    }
  }

  bool _isExpired(dynamic rawDate) {
    if (rawDate == null) return true;

    try {
      final createdAt = DateTime.parse(rawDate.toString()).toLocal();
      final expiryTime = createdAt.add(_confirmationWindow);
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();

    getFiredNotifications();

    // Rebuild every 30s so pending notifications flip to "expired"
    // live, without requiring a manual pull-to-refresh.
    _expiryTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _expiryTicker?.cancel();
    // Location tracking is no longer owned by this screen (see
    // LocationTrackingService above), so disposing this State must NOT
    // cancel it — that was the original bug. Nothing to cancel here now.
    super.dispose();
  }

  Widget _statusIcon({
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildPendingNotification(Map<String, dynamic> notification) {
    final bool expired = _isExpired(notification["createdAt"]);

    if (expired) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_off_rounded, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This confirmation window has expired.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        Text(
          "Your turn is within 15 minutes",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Please confirm whether you are coming to your scheduled slot.",
          style: TextStyle(fontSize: 12.5, height: 1.4, color: secondaryText),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 43,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // CHANGED: delegates to the singleton service instead of
                    // a local method, so tracking survives navigation away
                    // from this screen.
                    final started = await LocationTrackingService.instance.start();

                    if (!started) {
                      if (!mounted) return;
                      CherryToast.error(
                        title: const Text(
                          "Location permission is required to track your arrival.",
                        ),
                      ).show(context);
                      return;
                    }

                    // One-shot confirmation toast — replaces the old
                    // MaterialBanner, which depended on a context the
                    // service can no longer safely hold.
                    if (mounted) {
                      CherryToast.info(
                        title: const Text(
                          "Location tracking started, reach within the time limit.",
                        ),
                      ).show(context);
                    }

                    await updateAckStatus(notification["_id"]);
                  },
                  icon: const Icon(Icons.check_rounded, size: 17),
                  label: const Text(
                    "Coming",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: SizedBox(
                height: 43,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await updateNegAckStatus(notification["_id"]);
                  },
                  icon: const Icon(Icons.close_rounded, size: 17),
                  label: const Text(
                    "Not coming",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final acknowledged = notification["ackStatus"];

    final bool isComing = acknowledged == "comming";

    final bool isNotComing = acknowledged == "notcomming";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusIcon(
                  icon: isComing
                      ? Icons.check_circle_outline_rounded
                      : isNotComing
                      ? Icons.cancel_outlined
                      : Icons.notifications_none_rounded,
                  color: isComing
                      ? primaryGreen
                      : isNotComing
                      ? Colors.red.shade600
                      : primaryGreen,
                  background: isComing
                      ? lightGreen
                      : isNotComing
                      ? Colors.red.shade50
                      : lightGreen,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Queue Update",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "Your turn is within 15 mins",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _formatCreatedAt(notification["createdAt"]),
                        style: TextStyle(fontSize: 11, color: secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (isComing) ...[
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: primaryGreen,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        "Thank you for acknowledging. Please reach your slot on time.",
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isNotComing) ...[
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: Colors.red.shade600,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        "Your slot has been terminated.",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              _buildPendingNotification(notification),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAF9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        centerTitle: false,

        title: Text(
          "Notifications",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: darkText,
            letterSpacing: -0.3,
          ),
        ),

        iconTheme: IconThemeData(color: darkText),
      ),

      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: () => getFiredNotifications(),

        child: allNotifications.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.28),

                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: 78,
                          width: 78,
                          decoration: BoxDecoration(
                            color: lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 38,
                            color: primaryGreen,
                          ),
                        ),

                        const SizedBox(height: 17),

                        Text(
                          "No notifications yet",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Queue updates and important alerts\nwill appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),

                children: [
                  Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: primaryGreen,
                          size: 19,
                        ),
                      ),

                      const SizedBox(width: 9),

                      Text(
                        "${allNotifications.length} notification${allNotifications.length == 1 ? "" : "s"}",
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Divider(thickness: 0.5, color: Colors.grey.shade200),

                  const SizedBox(height: 15),

                  ...allNotifications.map(
                    (notification) => _buildNotificationCard(
                      Map<String, dynamic>.from(notification),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}