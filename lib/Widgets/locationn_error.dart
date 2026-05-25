import 'package:flutter/material.dart';

class LocationnError extends StatefulWidget {
  final Widget screen;
  const LocationnError({super.key,required this.screen});

  @override
  State<LocationnError> createState() => _LocationnErrorState();
}

class _LocationnErrorState extends State<LocationnError> {
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
              onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget.screen,)), child: Text("Try again",style: TextStyle(color: Colors.white),))
          ],
        ),
      ),
    );
  }
}