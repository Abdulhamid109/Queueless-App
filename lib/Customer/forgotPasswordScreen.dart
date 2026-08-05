import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:queueless/Customer/otpScreen.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';

class Forgotpasswordscreen extends StatefulWidget {
  const Forgotpasswordscreen({super.key});

  @override
  State<Forgotpasswordscreen> createState() => _ForgotpasswordscreenState();
}

class _ForgotpasswordscreenState extends State<Forgotpasswordscreen> {
  TextEditingController registeredEmailController = TextEditingController();
  
  Future <void> postForgotPassword ()async{
    try {
      final response = await http.post(Uri.parse("$BaseUrl/customer/auth/forgot-password"),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        "email":registeredEmailController.text.toLowerCase().trim().toString()
      })
      );

      if(response.statusCode==200){
        CherryToast.success(
          title: Text("Email Sent successfully"),
        ).show(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => OTPScreen(registeredEmail: registeredEmailController.text.toLowerCase().trim().toString(),reason: "forgotpassword",),));

      }
      if(response.statusCode!=200){
        final resbody = await jsonDecode(response.body);
        debugPrint("Error => ${resbody} - ${response.statusCode}");
        debugPrint("Error => ${response.body} - ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error => $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: height * 0.02),
              Text("Enter the Registered Email for OTP"),
              SizedBox(height: height * 0.02),
              TextFormField(
                controller: registeredEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter Your email",
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter your email";
                  }
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
                  );
                  if (!emailRegex.hasMatch(v.trim())) {
                    return "Enter a valid email";
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
                  onPressed: () async{
                    await postForgotPassword();
                  },
                  child: Text("Get OTP", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
