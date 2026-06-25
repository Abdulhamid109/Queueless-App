import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/locationn_error.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/RequestLocationPermission.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {




  Future locationStreaming() async {
    final isLocationEnabled = await requestLocationPermission();
    if(!isLocationEnabled){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LocationnError(screen: NotificationScreen()),));
      return;
    }
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((Position position) {
      sendlingLocationToBackend(position.latitude, position.longitude);
    });
  }

  Future sendlingLocationToBackend(latitude, longitude) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedData = JwtDecoder.decode(token!);
      final uid = decodedData["uid"];
      final response = await http.post(
        Uri.parse("$BaseUrl/customer/getLiveLocation/$uid"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({latitude, longitude}),
      );

      if (response.statusCode == 200) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showMaterialBanner(
          MaterialBanner(
            backgroundColor: Colors.green.shade100,
            content: Text(
              "Location tracking started , reach within the time limits",
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.black38,
                ),
                onPressed: () {
                  messenger.hideCurrentMaterialBanner();
                },
                child: Text("Close", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        Future.delayed(Duration(seconds: 5), () {
          messenger.hideCurrentMaterialBanner();
        });
      }
    } catch (e) {
      print("Error occured while updating the live locations => $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications"), centerTitle: true),
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
                  child: Text("Your turn will be in 15 mins on DJ Hairs"),
                ),
                subtitle: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async{
                        await locationStreaming();
                      },
                      child: Text(
                        "Comming",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        //send the notification to users who have marked flexible so that they can come in the queue..
                      },
                      child: Text(
                        "Not comming",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
