import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:queueless/Customer/FeedbackScreen.dart';
import 'package:queueless/Customer/LoginScreen.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  bool isloading = false;
  Future<Map<String, dynamic>>? _profileDataFuture;

  Future<Map<String, dynamic>> getProfile() async {
    setState(() {
      isloading = true;
    });
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
        print("Body => $responsebody");
        return responsebody;
      }
      throw Exception("Failed to fetch profile data");
    } catch (e) {
      print("Error $e");
      throw Exception("Error => $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> _handleNotificationTap(BuildContext context) async {
    try {
      final status = await Permission.notification.status;

      if (status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Notifications are already enabled")),
          );
        }
        return;
      }

      if (status.isDenied) {
        final result = await Permission.notification.request();
        debugPrint("Request result: $result");

        if (result.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Notifications enabled")));
          }
          return;
        }

        if (result.isDenied && context.mounted) {
          _showEnableNotificationDialog(context);
        }
        if (result.isPermanentlyDenied && context.mounted) {
          _showEnableNotificationDialog(context);
        }
        return;
      }

      if (status.isPermanentlyDenied && context.mounted) {
        _showEnableNotificationDialog(context);
      }
    } catch (e) {
      debugPrint("Notification permission error: $e");
    }
  }

  void _showEnableNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enable Notifications"),
        content: Text(
          "Turn on notifications to get updates when your turn is coming up in the queue.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Not Now"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _profileDataFuture = getProfile();
  }

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height;

    final Color primaryGreen = const Color(0xFF159447);
    final Color lightGreen = const Color(0xFFEAF7EF);
    final Color darkText = const Color(0xFF171717);
    final Color secondaryText = const Color(0xFF777777);
    final Color background = const Color(0xFFF9FAF9);

    return Scaffold(
      backgroundColor: background,

      appBar: Customerappbar(),

      drawer: Customerdrawer(),

      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileDataFuture,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),

                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                        width: 30,

                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Loading your profile...",
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(25),

                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      Container(
                        height: 70,
                        width: 70,

                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),

                        child: Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade400,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Unable to load profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Something went wrong while fetching your profile.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!["Data"];

              final String name = data["name"]?.toString() ?? "";

              final String email = data["email"]?.toString() ?? "";

              final String phone = data["phone"]?.toString() ?? "Not provided";

              final String address =
                  data["CustomerAddress"]?.toString() ?? "Not provided";

              final String role = data["role"]?.toString() ?? "";

              final String avatarInitials = name
                  .split(" ")
                  .where((n) => n.isNotEmpty)
                  .map((n) => n[0])
                  .join("")
                  .toUpperCase();

              return Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 35),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Account",

                      style: TextStyle(fontSize: 13, color: secondaryText),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Your Profile",

                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Row(
                        children: [
                          Container(
                            height: 64,
                            width: 64,

                            decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(18),
                            ),

                            alignment: Alignment.center,

                            child: Text(
                              avatarInitials.isEmpty ? "?" : avatarInitials,

                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: primaryGreen,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  name.isEmpty ? "User" : name,

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: darkText,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  email,

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: secondaryText,
                                  ),
                                ),

                                if (role.isNotEmpty) const SizedBox(height: 8),

                                if (role.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),

                                    decoration: BoxDecoration(
                                      color: lightGreen,
                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        Container(
                                          height: 6,
                                          width: 6,

                                          decoration: BoxDecoration(
                                            color: primaryGreen,
                                            shape: BoxShape.circle,
                                          ),
                                        ),

                                        const SizedBox(width: 5),

                                        Text(
                                          role,

                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    Text(
                      "Personal Information",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Column(
                        children: [
                          _buildProfileInfoTile(
                            icon: Icons.person_outline_rounded,
                            title: "Full Name",
                            value: name.isEmpty ? "Not provided" : name,
                            primaryGreen: primaryGreen,
                            darkText: darkText,
                            secondaryText: secondaryText,
                          ),

                          Divider(height: 1, color: Colors.grey.shade200),

                          _buildProfileInfoTile(
                            icon: Icons.email_outlined,
                            title: "Email",
                            value: email.isEmpty ? "Not provided" : email,
                            primaryGreen: primaryGreen,
                            darkText: darkText,
                            secondaryText: secondaryText,
                          ),

                          Divider(height: 1, color: Colors.grey.shade200),

                          _buildProfileInfoTile(
                            icon: Icons.phone_outlined,
                            title: "Phone Number",
                            value: phone,
                            primaryGreen: primaryGreen,
                            darkText: darkText,
                            secondaryText: secondaryText,
                          ),

                          Divider(height: 1, color: Colors.grey.shade200),

                          _buildProfileInfoTile(
                            icon: Icons.location_on_outlined,
                            title: "Address",
                            value: address,
                            primaryGreen: primaryGreen,
                            darkText: darkText,
                            secondaryText: secondaryText,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    Text(
                      "Settings",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Column(
                        children: [
                          _buildSettingTile(
                            icon: Icons.notifications_none_rounded,

                            title: "Notifications",

                            subtitle: "Manage queue notifications",

                            primaryGreen: primaryGreen,

                            darkText: darkText,

                            secondaryText: secondaryText,

                            onTap: () => _handleNotificationTap(context),
                          ),

                          Divider(
                            height: 1,
                            indent: 65,
                            color: Colors.grey.shade200,
                          ),

                          _buildSettingTile(
                            icon: Icons.chat_bubble_outline_rounded,

                            title: "Send Feedback",

                            subtitle: "Help us improve Queueless",

                            primaryGreen: primaryGreen,

                            darkText: darkText,

                            secondaryText: secondaryText,

                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Feedbackscreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    Text(
                      "Account Actions",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 46,

                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,

                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),

                                title: Row(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 35,

                                      decoration: BoxDecoration(
                                        color: lightGreen,
                                        borderRadius: BorderRadius.circular(9),
                                      ),

                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: primaryGreen,
                                        size: 19,
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    const Text("Under Development"),
                                  ],
                                ),

                                content: const Text(
                                  "The Edit Profile functionality is of mid to low priority and will be developed in upcoming builds.",
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),

                                    child: Text(
                                      "Close",
                                      style: TextStyle(color: primaryGreen),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },

                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: primaryGreen,
                        ),

                        label: Text(
                          "Edit Profile",

                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: primaryGreen,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: primaryGreen.withOpacity(0.35),
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 46,

                      child: ElevatedButton.icon(
                        onPressed: () {
                          onhandleLogout(context, LoginScreen());
                        },

                        icon: const Icon(Icons.logout_rounded, size: 18),

                        label: const Text(
                          "Logout",

                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,

                          foregroundColor: Colors.white,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Center(
                      child: Text(
                        "Queueless",

                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color primaryGreen,
    required Color darkText,
    required Color secondaryText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            height: 38,
            width: 38,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, size: 19, color: primaryGreen),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(fontSize: 11.5, color: secondaryText),
                ),

                const SizedBox(height: 4),

                Text(
                  value,

                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryGreen,
    required Color darkText,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),

          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EF),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(icon, size: 20, color: primaryGreen),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,

                      style: TextStyle(fontSize: 11.5, color: secondaryText),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
