import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  bool isloading = false;
  Future<Map<String, dynamic>>? _profileDataFuture;

  Future<Map<String, dynamic>> getProfile() async {
    setState(() {
      isloading = true;
    });
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
        print("Body => $responsebody");
        return responsebody;
      }
      throw Exception("Failed to fetch profile data");
    } catch (e) {
      print("Error $e");
      throw Exception("Error => $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _profileDataFuture = getProfile();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      appBar: Customerappbar(),
      drawer: Customerdrawer(),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text("Something went wrong => ${snapshot.error}");
            } else if (snapshot.hasData) {
              final avatarIntials = snapshot.data!["Data"]["name"]
                  .toString()
                  .split(" ")
                  .map((n) => n[0])
                  .join("")
                  .toUpperCase();
              print(avatarIntials);
              return Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Opacity(opacity: 0.5, child: Text("Account")),
                    Text(
                      "Your Profile",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            radius: 30,
                            child: Text(avatarIntials),
                          ),
                          title: Text(snapshot.data!["Data"]["name"]),
                          subtitle: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(snapshot.data!["Data"]["email"]),
                              SizedBox(height: height * 0.01),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    245,
                                    244,
                                    241,
                                  ),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    snapshot.data!["Data"]["role"],
                                    style: TextStyle(
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Opacity(opacity: 0.5, child: Text("PERSONAL INFORMATION")),
                    SizedBox(height: height * 0.02),
                    Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.person),
                              ),
                            ),
                            title: Opacity(
                              opacity: 0.5,
                              child: Text("Full Name"),
                            ),
                            subtitle: Text(
                              snapshot.data!["Data"]["name"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(thickness: 0.3),
                          ListTile(
                            leading: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.email),
                              ),
                            ),
                            title: Opacity(opacity: 0.5, child: Text("Email")),
                            subtitle: Text(
                              snapshot.data!["Data"]["email"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(thickness: 0.3),
                          ListTile(
                            leading: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.phone),
                              ),
                            ),
                            title: Opacity(
                              opacity: 0.5,
                              child: Text("Phone No"),
                            ),
                            subtitle: Text(
                              snapshot.data!["Data"]["phone"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(thickness: 0.3),
                          ListTile(
                            leading: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.location_pin),
                              ),
                            ),
                            title: Opacity(
                              opacity: 0.5,
                              child: Text("Address"),
                            ),
                            subtitle: Text(
                              snapshot.data!["Data"]["CustomerAddress"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.02),
                    Opacity(opacity: 0.5, child: Text("SETTINGS")),
                    SizedBox(height: height * 0.02),

                    Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.notifications),
                              ),
                            ),
                            title: Text("Notifications"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 12),
                          ),
                          Divider(thickness: 0.3),
                          ListTile(
                            leading: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.lock),
                              ),
                            ),
                            title: Text("Change Password"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 12),
                          ),
                          Divider(thickness: 0.3),
                          ListTile(
                            leading: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.feedback),
                              ),
                            ),
                            title: Text("Send Feedback"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 12),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.04),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    10,
                                  ),
                                ),
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () {},
                              child: Text(
                                "Edit",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    10,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                onhandleLogout(context);
                              },
                              child: Text(
                                "Logout",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return Text("");
          },
        ),
      ),
    );
  }
}
