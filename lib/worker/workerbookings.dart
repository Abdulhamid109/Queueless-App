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
  const WorkerBookingsPage({super.key, required this.date, required this.aboutPage});

  @override
  State<WorkerBookingsPage> createState() => _WorkerBookingsPageState();
}

class _WorkerBookingsPageState extends State<WorkerBookingsPage> {
  List bookingsList = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> getBookingBasedOnDate() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final decodedToken = JwtDecoder.decode(token!);
    final workerID = decodedToken["wid"];
    // debugPrint("workerID=> $workerID");

    final response = await http.get(
      Uri.parse("$BaseUrl/worker/getWorkerBookingsBasedOnDate/$workerID?date=${widget.date}"),
      headers: {'Content-Type': 'application/json'},
    );

    // debugPrint("Im here => ${response}");

    if (response.statusCode == 200) {
      final resbody = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        bookingsList = resbody["data"] ?? [];
        isLoading = false;
      });
      debugPrint("All Bookings => $bookingsList");
    }

    if(response.statusCode!=200){
      debugPrint("Error ${response.statusCode} - ${response.body}");
      throw Exception("Error ${response.statusCode} - ${response.body}");
    }
    
    //  else {
    // }
  } catch (e) {
    debugPrint("Error => $e");
    if (!mounted) return;
    setState(() {
      errorMessage = e.toString();
      isLoading = false;
    });
  }
}

  @override
  void initState() {
    super.initState();
    getBookingBasedOnDate();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      appBar: WorkerAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: height * 0.03),
            Center(
              child: Text(
                widget.aboutPage,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: height * 0.03),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(child: Text("Something went wrong: $errorMessage"))
            else if (bookingsList.isEmpty)
              const Center(child: Text("No bookings for this date"))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: bookingsList.length,
                  itemBuilder: (context, index) {
                    final booking = bookingsList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        child: ListTile(
                          title: Text("Customer Name: ${booking['customerName'] ?? 'Unknown'}"),
                          subtitle: Text("Position: #${booking['position'] ?? '-'}"),
                          
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}