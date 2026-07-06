import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:queueless/Customer/QueueScreen.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/Widgets/locationn_error.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/RequestLocationPermission.dart';

class Businesscategoryscreen extends StatefulWidget {
  final String bCategory;

  const Businesscategoryscreen({super.key, required this.bCategory});

  @override
  State<Businesscategoryscreen> createState() => _BusinesscategoryscreenState();
}

class _BusinesscategoryscreenState extends State<Businesscategoryscreen> {
  List<dynamic> allbusiness = [];
  bool isloading = false;
  bool hasLoaded = false;
  double latitude = 0;
  double longitude = 0;

  Future<void> getCurrentLocation() async {
    final PermissionGranted = await requestLocationPermission();
    if (!PermissionGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationnError(
            screen: Businesscategoryscreen(bCategory: widget.bCategory),
          ),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    await getAllBusinessBasedOnCategory();
  }

  Future getAllBusinessBasedOnCategory() async {
    setState(() {
      isloading = true;
    });
    try {
      final response = await http.post(
        Uri.parse("$BaseUrl/customer/getBusinessBasedOnCat/${widget.bCategory}"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {

        setState(() {
          allbusiness = responseBody["data"];
        });
      }
      if(response.statusCode!=200){
        throw Exception("Error => ${response.statusCode} -- ${response.body}");
      }
    } catch (e) {
      print("Error Occured! => $e");
    } finally {
      setState(() {
        isloading = false;
        hasLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: Customerappbar(),
        drawer: Customerdrawer(),
        body: RefreshIndicator(
          onRefresh: ()=>getCurrentLocation(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${widget.bCategory} Near You!",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.green, size: 15),
                        Text(
                          isloading
                              ? "Finding businesses..."
                              : "${allbusiness.length} Business found",
                        ),
                      ],
                    ),
                  ),
                
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search Business Name",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Divider(),
                  SizedBox(height: height * 0.02),
                
                  if (!hasLoaded || isloading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFFC9A96E),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Finding businesses near you...",
                              style: TextStyle(
                                color: Color(0xFF8A7E72),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (allbusiness.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.store_mall_directory_outlined,
                              size: 48,
                              color: Color(0xFFE8E1D8),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No ${widget.bCategory} found nearby",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Try expanding your search radius.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8A7E72),
                              ),
                            ),
                            SizedBox(height: 16),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Enter the radius (5KM to 10KM)",
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                                    ),
                                  ),
                                ),
                            // SizedBox(height: 7),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                  icon: Icon(Icons.refresh, size: 16),
                                  label: Text("Fetch"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Color(0xFF1A1A2E),
                                    side: BorderSide(color: Color(0xFFE8E1D8)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      itemCount: allbusiness.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final data = allbusiness[index];
                        final avatarInitials = data["BusinessName"]
                            .toString()
                            .split(" ")
                            .map((n) => n[0])
                            .join("")
                            .toUpperCase();
                
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE8E1D8)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFF5C97A),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        avatarInitials,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFC9A96E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data["BusinessName"],
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A1A2E),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_pin,
                                                size: 13,
                                                color: Color(0xFF8A7E72),
                                              ),
                                              SizedBox(width: 3),
                                              Expanded(
                                                child: Text(
                                                  data["BusinessAddress"],
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF8A7E72),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(
                                  color: Color(0xFFE8E1D8),
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.social_distance_sharp,
                                          size: 16,
                                          color: Color(0xFF8A7E72),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "${double.parse(data["distance"].toString()).toStringAsFixed(2)} m",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF8A7E72),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>Navigator.push(context, MaterialPageRoute(builder: (context) => Queuescreen(bid: data["_id"], bname: data["BusinessName"], baddress: data["BusinessAddress"]),)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1A1A2E),
                                        foregroundColor: const Color(0xFFF5F0EB),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 9,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Open",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}