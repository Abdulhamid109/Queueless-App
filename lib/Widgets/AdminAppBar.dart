import 'package:flutter/material.dart';
import 'package:queueless/admin/ProfilePage.dart';

class Adminappbar extends StatelessWidget
    implements PreferredSizeWidget {

  const Adminappbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {

    return AppBar(
      title: const Text("Queueless-Admin",style: TextStyle(color: Colors.green),),
      centerTitle: true,

      actions: [

        CircleAvatar(
          backgroundColor: Colors.blueGrey.shade100,
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Profilepage(),
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