import 'dart:convert';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Customer/BusinessCategoryScreen.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';
import 'package:queueless/Widgets/locationn_error.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/Notification_Service.dart';
import 'package:queueless/helper/RequestLocationPermission.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Future locationCheck() async {
    try {
      final permissionGranted = await requestLocationPermission();

      if (!permissionGranted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationnError(screen: Homescreen()),
          ),
        );
        return;
      }
    } catch (e) {
      print("Error $e");
    }
  }

  Future<Map<String, dynamic>>? _profileDataFuture;

  Future<Map<String, dynamic>> getProfile() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      final token = pref.getString("token");
      final decodedData = JwtDecoder.decode(token!);
      final id = decodedData["uid"];

      final response = await http.get(
        Uri.parse("$BaseUrl/customer/profile/$id"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responsebody = jsonDecode(response.body);
        return responsebody;
      }

      throw Exception("Failed to fetch profile data");
    } catch (e) {
      print("Error $e");
      throw Exception("Error => $e");
    }
  }

  Future updateFCM() async {
    try {
      NotificationService notificationService = NotificationService();

      final FCMToken = await notificationService.getFCMToken();

      SharedPreferences preferences = await SharedPreferences.getInstance();

      final token = preferences.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final uid = decodedToken["uid"];

      final response = await http.put(
        Uri.parse("$BaseUrl/customer/updateFCM/$uid"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"fcmToken": FCMToken}),
      );

      if (response.statusCode == 200) {
        print("Successfully fetched the FCM");
      }

      if (response.statusCode != 200) {
        final errorbody = jsonDecode(response.body);

        CherryToast.error(title: Text("${errorbody["error"]}"));
      }
    } catch (e) {
      print("Error => $e");
    }
  }

  @override
  void initState() {
    super.initState();

    locationCheck();

    _profileDataFuture = getProfile();

    NotificationService notificationService = NotificationService();

    notificationService.requestLNotificationPermission();
    notificationService.getFCMToken();
    notificationService.initLocalNotifications();

    updateFCM();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      notificationService.showNotification(message);
    });

    updateFCM();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;

    double width = MediaQuery.of(context).size.width * 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),

      appBar: Customerappbar(),

      drawer: Customerdrawer(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WELCOME BACK",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 8),

            FutureBuilder(
              future: _profileDataFuture,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                } else if (asyncSnapshot.hasError) {
                  return Text(
                    "Something went wrong => ${asyncSnapshot.error}",
                    style: TextStyle(color: Colors.grey.shade600),
                  );
                } else if (asyncSnapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asyncSnapshot.data!["Data"]["name"] ?? "Tony Stark",
                        style: const TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7EF),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              size: 17,
                              color: Color(0xFF159447),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              asyncSnapshot.data!["Data"]["CustomerAddress"] ??
                                  "Miraj-MH10",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return const Text("");
              },
            ),

            const SizedBox(height: 28),

            Text(
              "BROWSE CATEGORY",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 10),

            DropdownMenu(
              width: width - 44,

              hintText: "Select Business Categories",

              leadingIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF159447),
              ),

              menuStyle: MenuStyle(
                backgroundColor: const WidgetStatePropertyAll(Colors.white),
              ),

              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF159447),
                    width: 1.2,
                  ),
                ),
              ),

              dropdownMenuEntries: const [
                DropdownMenuEntry(value: "HairSaloon", label: "Hair Saloons"),
                DropdownMenuEntry(value: "Clinics", label: "Clinics"),
              ],

              onSelected: (value) {
                if (value == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Businesscategoryscreen(bCategory: value),
                  ),
                );
              },
            ),

            SizedBox(height: height * 0.045),

            Divider(thickness: 0.5, color: Colors.grey.shade200),

            SizedBox(height: height * 0.035),

            Text(
              "BUSINESS CATEGORIES",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 12),

            _businessCategoryCard(
              icon: Icons.content_cut_rounded,
              title: "Hair Saloons",
              subtitle: "Find all hair saloons near you",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Businesscategoryscreen(bCategory: "HairSaloon"),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _businessCategoryCard(
              icon: Icons.medical_services_outlined,
              title: "Clinics",
              subtitle: "Find all clinics near you",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Businesscategoryscreen(bCategory: "Clinics"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _businessCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF159447), size: 27),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF171717),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
