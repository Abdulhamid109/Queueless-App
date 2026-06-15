import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  Future locationStreaming ()async{
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20
      )
    ).listen((Position position){

    });
  }

  Future sendlingLocationToBackend ()async{
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.notifications_none),
              // Text("No Notifcations found!")
              ListTile(
                tileColor: Colors.grey.shade100,
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Your turn will be in 15 mins"),
                ),
                subtitle: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.green
                      ),
                      onPressed: (){}, child: Text("Comming",style: TextStyle(color: Colors.white),)),
                    SizedBox(width: 5,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.red
                      ),
                      onPressed: (){}, child: Text("Not comming",style: TextStyle(color: Colors.white),)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}