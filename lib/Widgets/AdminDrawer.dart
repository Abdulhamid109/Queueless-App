import 'package:flutter/material.dart';
import 'package:queueless/admin/AdminHomePage.dart';
import 'package:queueless/admin/BusinessOnboarding/businessInformation.dart';
import 'package:queueless/admin/LoginScreen.dart';
import 'package:queueless/admin/ProfilePage.dart';
import 'package:queueless/admin/qlbusinesspage.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';

class Admindrawer extends StatelessWidget {
  const Admindrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Drawer(
      backgroundColor: const Color(0xFFF5F7FA),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            _buildHeader(primaryColor),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerTile(
                    icon: Icons.home_outlined,
                    title: "Home",
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Adminhomepage(),
                      ),
                    ),
                  ),
                  _buildDrawerTile(
                    icon: Icons.storefront_outlined,
                    title: "Business Profile",
                    color: primaryColor,
                    onTap: () =>Navigator.push(context, MaterialPageRoute(builder: (context) => Profilepage(),)),
                  ),
                  _buildDrawerTile(
                    icon: Icons.add_business_outlined,
                    title: "Add Business",
                    color: primaryColor,
                    onTap: () =>Navigator.push(context, MaterialPageRoute(builder: (context) => Businessinformation(),)),
                  ),
                  _buildDrawerTile(
                    icon: Icons.info_outline,
                    title: "About QL Business",
                    color: primaryColor,
                    onTap: () =>Navigator.push(context, MaterialPageRoute(builder: (context) => AboutQueuelessScreen(),)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.red,
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await onhandleLogout(context, AdminLoginScreen());
                  },
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.75)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            "Queueless",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "Admin Panel",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
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