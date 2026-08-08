import 'package:flutter/material.dart';
import 'package:queueless/Customer/AboutusScreen.dart';
import 'package:queueless/Customer/ContactScreen.dart';
import 'package:queueless/Customer/FeedbackScreen.dart';
import 'package:queueless/Customer/HomeScreen.dart';
import 'package:queueless/Customer/LoginScreen.dart';
import 'package:queueless/Customer/ProfileScreen.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';

class Customerdrawer extends StatefulWidget {
  const Customerdrawer({super.key});

  @override
  State<Customerdrawer> createState() => _CustomerdrawerState();
}

class _CustomerdrawerState extends State<Customerdrawer> {
  final Color primaryGreen = const Color(0xFF159447);
  final Color lightGreen = const Color(0xFFEAF7EF);
  final Color darkText = const Color(0xFF171717);
  final Color secondaryText = const Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/file_000000008ee471fd93c3f86bb8fcc4c7.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "Queueless",
                    style: TextStyle(
                      color: darkText,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Wait less. Live more.",
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _drawerItem(
                    icon: Icons.home_outlined,
                    title: "Home",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Homescreen()),
                      );
                    },
                  ),

                  _drawerItem(
                    icon: Icons.person_outline_rounded,
                    title: "Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Profilescreen(),
                        ),
                      );
                    },
                  ),

                  _drawerItem(
                    icon: Icons.info_outline_rounded,
                    title: "About us",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Aboutusscreen(),
                        ),
                      );
                    },
                  ),

                  _drawerItem(
                    icon: Icons.phone_outlined,
                    title: "Contact",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Contactscreen(),
                        ),
                      );
                    },
                  ),

                  _drawerItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "Feedback",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Feedbackscreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  Divider(color: Colors.grey.shade200, height: 1),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        onhandleLogout(context, LoginScreen());
                      },
                      icon: const Icon(Icons.logout_rounded, size: 19),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "Queueless",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    "Wait less. Live more.",
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 21, color: primaryGreen),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: darkText,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
