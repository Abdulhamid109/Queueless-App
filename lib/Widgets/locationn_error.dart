import 'package:flutter/material.dart';
import 'package:queueless/Customer/SignupScreen.dart';

class LocationnError extends StatelessWidget {
  const LocationnError({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Location Error...Kindly on the location to proceed furthur"),
            SizedBox(height: 15,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                backgroundColor: Colors.red
              ),
              onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen(),)), child: Text("Try again",style: TextStyle(color: Colors.white),))
          ],
        ),
      ),
    );
  }
}