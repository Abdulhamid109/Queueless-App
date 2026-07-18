import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
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

  List allNotifications =[];

  Future getFiredNotifications()async{
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final token = preferences.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final uid = decodedToken["uid"];
      debugPrint("Uid => $uid");
      final response = await http.get(Uri.parse("$BaseUrl/customer/getNotifications/$uid"),
      headers: {"Content-Type":'application/json'}
      );
      if(response.statusCode==200){
        final respbody = jsonDecode(response.body);
        setState(() {
          allNotifications = respbody["data"];
          print("All Notifications $allNotifications");
        });
      }

      if(response.statusCode!=200){
        CherryToast.error(
          title: Text("Something went wrong"),
        );
        throw Exception("Error => ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("error => $e");
    }
  }


  Future updateAckStatus (String notificationId)async{
    try {
      final response = await http.put(Uri.parse("$BaseUrl/customer/updateAckStatus/$notificationId"),
      headers: {'Content-Type':'application/json'}
      );
      if(response.statusCode==200){
        CherryToast.success(
          title: Text("Your Slot has been confirmed kindly reach fast!"),
        );
      }
      if(response.statusCode!=200){
        CherryToast.error(
          title: Text("Something went wrong!"),
        );
        throw Exception("Error => ${response.statusCode} -- ${response.body}");
      }
    } catch (e) {
      print("Error => $e");
    }
  }



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
        body: jsonEncode(
          {
            "latitude": latitude,
  "longitude": longitude,
          }
        ),
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
  void initState() {
    super.initState();
    getFiredNotifications();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Notifications"), centerTitle: true),
    body: allNotifications.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text("No Notifications found!"),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: allNotifications.length,
            itemBuilder: (context, index) {
              final notification = allNotifications[index];
              debugPrint("Notification - Data => $notification");
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  tileColor: Colors.grey.shade100,
                  title: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Your turn is within 15 mins"),
                  ),
                  subtitle: notification["ackStatus"]
                  ?Text("Thankyou for acknowledgment")
                  :Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          await locationStreaming();
                          await updateAckStatus(notification["_id"]);
                        },
                        child: const Text(
                          "Coming",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          // send notification to flexible-marked users
                        },
                        child: const Text(
                          "Not coming",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    
                    ],
                  )
                  
                  ),
              );
            },
          ),
  );
}
}
