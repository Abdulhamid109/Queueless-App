import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/WorkerAppbar.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerBookingsPage extends StatefulWidget {
  final String date;
  final String aboutPage;
  // final String wid;
  const WorkerBookingsPage({super.key,required this.date,required this.aboutPage});

  @override
  State<WorkerBookingsPage> createState() => _WorkerBookingsPageState();
}

class _WorkerBookingsPageState extends State<WorkerBookingsPage> {

  List bookingsList = [];

  Future getBookingBasedOnDate ()async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final workerID = decodedToken["wid"];
      final response = await http.get(Uri.parse("$BaseUrl/worker/getBookingsBasedOnDate/$workerID?date=${widget.date}"),
      headers: {'Content-Type':'application/json'}
      );
      if(response.statusCode==200){
        final resbody = jsonDecode(response.body);
        setState(() {
          bookingsList = resbody["data"];
        });
        // return resbody;
      }
      if(response.statusCode!=200){
        throw Exception("Error ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      // print("Error => $e");
      throw "Error = > $e";
    }
  }

  DateTime dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width*1;
    double height = MediaQuery.of(context).size.height*1;
    return Scaffold(
      appBar: WorkerAppbar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: height*0.03,),
            // Text("Date ${dateTime.day}/${dateTime.month}/${dateTime.year}"),
            // Text("Date ${widget.date}"),
            // SizedBox(height: 0.03,),
            Center(child: Text(widget.aboutPage,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)),
            SizedBox(height: height*0.03,),
            
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text("Abdulhamid Patel "),
                  subtitle: Text("Position :#1"),
                ),
              ),
            ),
            
            SizedBox(height: height*0.01,),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text("Customer Name : Abdulhamid Patel "),
                  subtitle: Text("Position :#2"),
                ),
              ),
            )
          
          
          
          
          ],
                ),
        ),),
    );
  }
}