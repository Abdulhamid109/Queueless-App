import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:queueless/admin/AdminHomePage.dart';
import 'package:queueless/admin/BusinessOnboarding/WorkerInformation.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/models/WorkerInformationModal.dart';
import 'package:queueless/models/businessInformationModal.dart';
import 'package:queueless/models/serviceInformationModal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Timeinformation extends StatefulWidget {
  const Timeinformation({super.key});

  @override
  State<Timeinformation> createState() => _TimeinformationState();
}

class _TimeinformationState extends State<Timeinformation> {
  String StarttimeOfDay = "";
  String EndtimeOfDay = "";
  TextEditingController totalCustomer = TextEditingController();
  TextEditingController additionalInformation = TextEditingController();
  var businessInfoBox = Hive.box<Businessinformationmodal>("BusinessBox");
  var workerInfoBox = Hive.box<Workerinformationmodal>("WorkerBox");
  var serviceInfoBox = Hive.box<Serviceinformationmodal>("ServiceBox");
  String statusString = "";
  bool isloading = false;

  Future<String> getCurrentUserDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    final decodedData = JwtDecoder.decode(token!);
    return decodedData["uid"];
  }

  Future<void> handlebusinessInfo() async {
    setState(() => isloading = true);
    try {
      final String uid = await getCurrentUserDetails();

      final businessInfo = businessInfoBox.get("BusinessInfo");

      if (businessInfo == null) {
        showDialog(
          barrierColor: Colors.black45,
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Center(child: Text("No Business Data Found. Try again.")),
          ),
        );
        setState(() => isloading = false);
        return;
      }

      setState(() => statusString = "Submitting business info...");

      final response = await http.post(
        Uri.parse("$BaseUrl/admin/addbusinessInfo"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "adminid": uid,
          "BusinessName": businessInfo.businessName,
          "BusinessAddress": businessInfo.businessAddress,
          "BusinessCategory": businessInfo.businessCategory,
          "Country": businessInfo.country,
          "State": businessInfo.state,
          "City": businessInfo.city,
          "pinCode": businessInfo.pinCode,
          "website": businessInfo.website,
          "latitude": businessInfo.latitude,
          "longitude": businessInfo.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        setState(() => statusString = "Business info added successfully");
        final pref = await SharedPreferences.getInstance();
        pref.remove("Step1");

        await handleWorkerLogic(jsonData["bid"]);
      } else {
        setState(() {
          statusString = "Failed: ${response.statusCode}";
          isloading = false;
        });
      }
    } catch (e) {
      setState(() {
        statusString = "Error adding business";
        isloading = false;
      });
    }
  }

  Future<void> handleWorkerLogic(String bid) async {
    try {
      setState(() => statusString = "Adding workers...");
      final String uid = await getCurrentUserDetails();
      final workerInfo = workerInfoBox.values.toList();

      for (var worker in workerInfo) {
        final response = await http.post(
          Uri.parse("$BaseUrl/admin/addworkerInfo"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "adminId": uid,
            "businessId": bid,
            "workerName": worker.WorkerName,
            "WorkerEmail": worker.WorkerEmail,
          }),
        );

        if (response.statusCode == 200) {
          setState(() => statusString = "Worker added ✓");
        }
      }

      await handleServiceLogic(bid);
    } catch (e) {
      setState(() {
        statusString = "Error adding workers";
        isloading = false;
      });
    }
  }

  Future<void> handleServiceLogic(String bid) async {
    try {
      setState(() => statusString = "Adding services...");
      final serviceInfo = serviceInfoBox.values.toList();

      for (var service in serviceInfo) {
        final response = await http.post(
          Uri.parse("$BaseUrl/admin/addserviceInfo"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "name": service.serviceName,
            "AvgDurationPerCustomer": service.serviceDuration,
            "ChargesPerService": service.serviceCharge,
            "businessId": bid,
          }),
        );

        if (response.statusCode == 200) {
          setState(() => statusString = "Service added successfully");
        }
      }

      await handleTimeInfo(bid);
    } catch (e) {
      setState(() {
        statusString = "Error adding services";
        isloading = false;
      });
    }
  }

  Future<void> handleTimeInfo(String bid) async {
    try {
      if (bid.isEmpty ||
          StarttimeOfDay.isEmpty ||
          EndtimeOfDay.isEmpty ||
          totalCustomer.text.isEmpty) {
        showDialog(
          barrierColor: Colors.black45,
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              "Kindly enter the time details",
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      }

      setState(() => statusString = "Adding time info...");

      final response = await http.post(
        Uri.parse("$BaseUrl/admin/addtimeInfo"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "BusinessID": bid,
          "BST": StarttimeOfDay,
          "BET": EndtimeOfDay,
          "CustomerLimitPerDay": totalCustomer.text,
          "AdditionalInformation": additionalInformation.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => statusString = "All done ✓");
        businessInfoBox.clear();
      workerInfoBox.clear();
      serviceInfoBox.clear();
      StarttimeOfDay = "";
      EndtimeOfDay = "";
      totalCustomer.clear();
      additionalInformation.clear();
        Navigator.push(context, MaterialPageRoute(builder: (context) => Adminhomepage(),));
      }
    } catch (e) {
      setState(() => statusString = "Error adding time info");
    } finally {
      setState(() => isloading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    double width = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: .start,
            children: <Widget>[
              Center(
                child: Text(
                  "Step 04 - Time Information",
                  textAlign: .center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: height * 0.1),

              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Align(
                          alignment: .topLeft,
                          child: Opacity(
                            opacity: 0.5,
                            child: Text(
                              "Business Start Time",
                              textAlign: .start,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              StarttimeOfDay.isEmpty
                                  ? Text("BST: ")
                                  : Text("BST : $StarttimeOfDay"),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );

                                  if (pickedTime != null) {
                                    setState(() {
                                      StarttimeOfDay = pickedTime.format(
                                        context,
                                      );
                                    });
                                  }
                                },
                                child: Text(
                                  "Select Start Time",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Align(
                          alignment: .topLeft,
                          child: Opacity(
                            opacity: 0.5,
                            child: Text("Business End Time", textAlign: .start),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              EndtimeOfDay.isEmpty
                                  ? Text("BET: ")
                                  : Text("BET : $EndtimeOfDay"),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );

                                  if (pickedTime != null) {
                                    setState(() {
                                      EndtimeOfDay = pickedTime.format(context);
                                    });
                                  }
                                },
                                child: Text(
                                  "Select End Time",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.01),
                      TextFormField(
                        controller: totalCustomer,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Total Customer Per Day",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      TextFormField(
                        controller: additionalInformation,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Additional Information (optional)",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.01),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            setState(() {
                              statusString = "starting with final submit";
                            });
                            await handlebusinessInfo();
                          },
                          child: isloading
                              ? Text(
                                  statusString,
                                  style: TextStyle(color: Colors.white),
                                )
                              : Text(
                                  "Submit",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
