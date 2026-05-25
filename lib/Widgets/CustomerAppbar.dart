import 'package:flutter/material.dart';
import 'package:queueless/Customer/ProfileScreen.dart';

class Customerappbar extends StatelessWidget
    implements PreferredSizeWidget {

  const Customerappbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {

    return AppBar(
      title: const Text("Queueless"),
      centerTitle: true,

      actions: [

        CircleAvatar(
          backgroundColor: Colors.blueGrey.shade100,
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Profilescreen(),
              ),
            ),

            icon: const Icon(
              Icons.person,
              size: 20,

            ),
          ),
        ),

        const SizedBox(width: 10),
      ],
    );
  }
}