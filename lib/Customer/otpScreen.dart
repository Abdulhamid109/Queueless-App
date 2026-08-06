import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/Customer/ChangePasswordScreen.dart';
import 'package:queueless/Customer/LoginScreen.dart';
import 'package:queueless/constant/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  final String registeredEmail;
  final String reason;
  const OTPScreen({
    super.key,
    required this.registeredEmail,
    required this.reason,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController OTP = TextEditingController();

  bool isloading = false;

  Future OTPValidation() async {
    setState(() {
      isloading = true;
    });
    try {
      final response = await http.post(
        Uri.parse("$BaseUrl/customer/auth/validateOTP"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"OTP": OTP.text, "email": widget.registeredEmail}),
      );

      if (response.statusCode == 200) {
        if (widget.reason.toLowerCase() == "signup") {
          //signup method;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final response = await http.post(
            Uri.parse("$BaseUrl/customer/auth/signup"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'FullName': prefs.getString("FullName"),
              'email': prefs.getString("email"),
              'password': prefs.getString("password"),
              'phone': prefs.getString("phone"),
              'CustomerAddress': prefs.getString("CustomerAddress"),
              'latitude': prefs.getDouble("latitude"),
              'longitude': prefs.getDouble("longitude"),
            }),
          );

          if (response.statusCode == 200) {
            print("Im here3");
            prefs.remove("FullName");
            prefs.remove("email");
            prefs.remove("password");
            prefs.remove("phone");
            prefs.remove("CustomerAddress");
            prefs.remove("latitude");
            prefs.remove("longitude");
            CherryToast.success(
              title: Text("Successfully account created!"),
            ).show(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
          if (response.statusCode != 200) {
            print(
              "Some Error happened with code as ${response.statusCode} => ${response.body} ",
            );
            var error = jsonDecode(response.body);
            final messenger = ScaffoldMessenger.of(context);
            messenger.showMaterialBanner(
              MaterialBanner(
                backgroundColor: Colors.red.shade200,
                leading: Icon(Icons.error, color: Colors.red),
                content: Text(error["error"]),
                actions: [
                  TextButton(
                    onPressed: () {
                      messenger.hideCurrentMaterialBanner();
                    },
                    child: Text(
                      "Dismiss",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            );
            Future.delayed(Duration(seconds: 5), () {
              if (messenger.mounted) {
                messenger.hideCurrentMaterialBanner();
              }
            });
          }
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Changepasswordscreen(email: widget.registeredEmail),
          ),
        );
      }
      if(response.statusCode!=200){
        final resbody = await jsonDecode(response.body);
          debugPrint("Error -> ${resbody["error"]} - ${response.statusCode}");
          CherryToast.error(
            title: Text(resbody["error"]),
          ).show(context);
        }
    } catch (e) {
      debugPrint("Error => $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(height: height*0.02,),
            Text("Enter Your OTP"),
            SizedBox(height: height * 0.02),
            TextFormField(
              controller: OTP,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "XXXXXX",
                focusedBorder: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Enter your OTP";
                }
                return null;
              },
            ),
            SizedBox(height: height * 0.01),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  await OTPValidation();
                },
                child: isloading
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        "Confirm OTP",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
