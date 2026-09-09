import 'package:flutter/material.dart';

class NetworkErrorScreen extends StatelessWidget {
  final VoidCallback onTryAgain;

  const NetworkErrorScreen({
    super.key,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 70,
            ),

            const SizedBox(height: 20),

            const Text(
              "No Internet Connection",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Please check your internet connection.",
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.red
              ),
              onPressed: onTryAgain,
              child: const Text("Try Again",style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}