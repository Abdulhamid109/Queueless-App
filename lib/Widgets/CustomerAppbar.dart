import 'package:flutter/material.dart';
import 'package:queueless/Customer/ProfileScreen.dart';
import 'package:queueless/Customer/notification.dart';

class Customerappbar extends StatelessWidget implements PreferredSizeWidget {
  const Customerappbar({super.key});

  final Color primaryGreen = const Color(0xFF159447);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF9FAF9),
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      titleSpacing: 4,

      title: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.route_rounded, color: primaryGreen, size: 21),
          ),

          const SizedBox(width: 10),

          const Text(
            "Queueless",
            style: TextStyle(
              color: Color(0xFF171717),
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),

      actions: [
        _appBarButton(
          context: context,
          icon: Icons.person_outline_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profilescreen()),
            );
          },
        ),

        const SizedBox(width: 4),

        _appBarButton(
          context: context,
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            );
          },
        ),

        const SizedBox(width: 12),
      ],
    );
  }

  Widget _appBarButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, size: 21, color: const Color(0xFF333333)),
        ),
      ),
    );
  }
}
