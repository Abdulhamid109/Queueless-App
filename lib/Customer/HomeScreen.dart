// On homepage also we need to ask for the location
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Customer/BusinessCategoryScreen.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';
import 'package:queueless/Widgets/locationn_error.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/RequestLocationPermission.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Future<void> locationCheck() async {
    try {
      final permissionGranted = await requestLocationPermission();
      if (!permissionGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocationnError(screen: Homescreen(),)),
      );
      return;
    }
    } catch (e) {
      print("Error $e");
    }
  }

  Future<Map<String, dynamic>>? _profileDataFuture;

  Future<Map<String, dynamic>> getProfile() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final decodedData = JwtDecoder.decode(token!);
      final id = decodedData["uid"];
      final response = await http.get(
        Uri.parse("$BaseUrl/customer/profile/$id"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responsebody = jsonDecode(response.body);
        // print("Body => $responsebody");
        return responsebody;
      }
      throw Exception("Failed to fetch profile data");
    } catch (e) {
      print("Error $e");
      throw Exception("Error => $e");
    }
  }

  @override
  void initState() {
    super.initState();
    locationCheck();
    _profileDataFuture = getProfile();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    double width = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      appBar: Customerappbar(),
      drawer: Customerdrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(opacity: 0.5, child: Text("WELCOME BACK")),
            SizedBox(height: 10),
            FutureBuilder(
              future: _profileDataFuture,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (asyncSnapshot.hasError) {
              return Text("Something went wrong => ${asyncSnapshot.error}");
            } else if (asyncSnapshot.hasData) {
                return Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      asyncSnapshot.data!["Data"]["name"]??"Tony Stark",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.green),
                        SizedBox(width: 5),
                        Opacity(
                          opacity: 0.5,
                          child: Text(
                            asyncSnapshot.data!["Data"]["CustomerAddress"]??"Miraj-MH10",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
            }
            return Text("");
              }
            ),
            SizedBox(height: 25),
        
            Opacity(opacity: 0.5, child: Text("BROWSE CATEGORY")),
            SizedBox(height: 12),
            DropdownMenu(
              width: width - 30,
              hintText: "Select Business Categories",
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: "HairSaloon",
                  label: "Hair Saloons",
                ),
                DropdownMenuEntry(value: "Clinics", label: "Clinics"),
              ],
              onSelected: (value) => {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Businesscategoryscreen(bCategory: value!),)),
              },
            ),
            SizedBox(height: height * 0.05),
            Divider(thickness: 0.3),
            SizedBox(height: height * 0.05),
            Text("BUSINESS CATEGORIES"),
            SizedBox(height: height * 0.01),
            Card(
              color: const Color.fromARGB(255, 208, 234, 255),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.cut),
                        ),
                      ),
                    ),
        
                    // SizedBox(height: height*0.01,),
                    ListTile(
                      title: Text("Hair Saloons"),
                      subtitle: Opacity(
                        opacity: 0.5,
                        child: Text("Find all hair saloons near you"),
                      ),
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => Businesscategoryscreen(bCategory: "HairSaloon"),)),
                    ),
                  ],
                ),
              ),
            ),
        
            SizedBox(height: height * 0.02),
            Card(
              color: const Color.fromARGB(255, 255, 208, 208),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.medical_services_rounded),
                        ),
                      ),
                    ),
        
                    // SizedBox(height: height*0.01,),
                    ListTile(
                      title: Text("Clinics"),
                      subtitle: Opacity(
                        opacity: 0.5,
                        child: Text("Find all Clinics near you"),
                      ),
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => Businesscategoryscreen(bCategory: "Clinics"),)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
