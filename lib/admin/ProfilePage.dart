import 'package:flutter/material.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';

class Profilepage extends StatelessWidget {
  const Profilepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: Center(
        child: Text("Admin Profile Page"),
      ),
    );
  }
}