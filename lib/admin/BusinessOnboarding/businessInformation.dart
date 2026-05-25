import 'package:flutter/material.dart';

class Businessinformation extends StatelessWidget {
  const Businessinformation({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: <Widget>[
            Text("Step 01 - Business Information")
          ],
        ),
      ),
    );
  }
}