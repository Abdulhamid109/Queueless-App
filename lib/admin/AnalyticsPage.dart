import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';

class Analyticspage extends StatefulWidget {
  final String bussinessId;
  final String businessName;
  final String businessAddress;
  const Analyticspage({
    super.key,
    required this.bussinessId,
    required this.businessAddress,
    required this.businessName,
  });

  @override
  State<Analyticspage> createState() => _AnalyticspageState();
}

class _AnalyticspageState extends State<Analyticspage> {

  Future <Map<String, dynamic>>? _timeDetails;
  
  Future<Map<String, dynamic>> getTimeDetails() async {
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/getTimeData/${widget.bussinessId}"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      }
      throw Exception("responseCode :${response.statusCode} ,Body :${response.body}");
    } catch (e) {
      print("Error => $e");
      throw "Error => $e";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timeDetails = getTimeDetails();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Business Details",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Business Name : ${widget.businessName}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Business Address : ${widget.businessAddress}",
                          ),
                        ),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _timeDetails,
                          builder: (context, snapshot) {
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return Center(child: CircularProgressIndicator(color: Colors.black,),);
                            }else if(snapshot.hasError){
                              return Text("Something went wrong => ${snapshot.error}");
                            }else if(snapshot.hasData){
                              return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Business Start Time : ${snapshot.data!["data"]["BST"]}"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Business End Time : ${snapshot.data!["data"]["BET"]}"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Customer Per Day : ${snapshot.data!["data"]["CustomerLimitPerDay"]}"),
                                ),
                              ],
                            );
                          
                            }
                            return Text("");
                            
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),
              Text(
                "Analytics & Growth",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),

              SizedBox(
                height: height * 0.1,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text("Expense Calculation")),
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),

              SizedBox(
                height: height * 0.1,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text("Customer Retention Trend")),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),
              Text(
                "Ratings",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),

              SizedBox(
                height: height * 0.1,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text("Business Rating Chart")),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),
              Text(
                "Feedbacks",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),

              SizedBox(
                height: height * 0.1,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text("Customer Feedbacks")),
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
