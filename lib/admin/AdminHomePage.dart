import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:queueless/admin/AnalyticsPage.dart';
import 'package:queueless/admin/BusinessEditPage.dart';
import 'package:queueless/admin/BusinessOnboarding/businessInformation.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Adminhomepage extends StatefulWidget {
  const Adminhomepage({super.key});

  @override
  State<Adminhomepage> createState() => _AdminhomepageState();
}

class _AdminhomepageState extends State<Adminhomepage> {
  List<dynamic> allbusiness = [];
  bool isloading = false;

  Future getAllRegisteredBusinesses()async{
    setState(() {
      isloading =true;
    });
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final decodedData = JwtDecoder.decode(token!);
      final response = await http.get(Uri.parse("$BaseUrl/admin/getBusinessData/${decodedData["uid"]}"),
      headers: {'Content-Type':'application/json'},
      );
      final data = jsonDecode(response.body);
      print("Data => ${data["data"]}");

      if(response.statusCode == 200){
        setState(() {
          allbusiness = data["data"];  
        });
      }
  } catch (e) {
      print("Error occured while fetching the busniess => $e");
    }finally{
      setState(() {
        isloading=false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllRegisteredBusinesses();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DASHBOARD",
                style: TextStyle(
                  color: const Color(0xFF8A7E72),
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                "Welcome Back, Admin",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: height * 0.005),
              Text(
                "${allbusiness.length} Business Registered!",
                style: TextStyle(
                  color: const Color(0xFF8A7E72),
                  fontSize: 13,
                ),
              ),

              SizedBox(height: height * 0.03),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Businesses",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Businessinformation(),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline_sharp,
                          size: 16,
                          color: const Color(0xFFC9A96E),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Add New",
                          style: TextStyle(
                            color: const Color(0xFFC9A96E),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.015),

              isloading?
              Center(child: Text("Loading...."),)
              :ListView.builder(
                shrinkWrap: true,
                itemCount: allbusiness.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final data = allbusiness[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8E1D8)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Color(0xFF8A7E72),
                            size: 22,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "${data["BusinessName"]}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              size: 14,
                              color: const Color(0xFF8A7E72),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "${data["BusinessAddress"]}",
                              style: TextStyle(
                                color: const Color(0xFF8A7E72),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Analyticspage(bussinessId: data["_id"],businessName: data["BusinessName"],businessAddress: data["BusinessAddress"],),));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: const Color(0xFFF5F0EB),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(
                                    "Manage",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5,),
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Businesseditpage(bid: data["_id"]),));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent.shade100,
                                    foregroundColor: const Color(0xFFF5F0EB),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          
                          ],
                        ),
                      ],
                    ),
                                    ),
                  
                  );
              
                },
               
              ),


              SizedBox(height: height * 0.015),

              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Businessinformation(),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE8E1D8),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_outlined,
                        size: 30,
                        color: const Color(0xFF8A7E72),
                      ),
                      SizedBox(height: height * 0.015),
                      Text(
                        "Add Business",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Click here to add a business",
                        style: TextStyle(
                          color: const Color(0xFF8A7E72),
                          fontSize: 12,
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