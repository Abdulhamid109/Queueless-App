import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/Customer/LoginScreen.dart';
import 'package:queueless/constant/env.dart';

class Changepasswordscreen extends StatefulWidget {
  final String email;
  const Changepasswordscreen({super.key, required this.email});

  @override
  State<Changepasswordscreen> createState() => _ChangepasswordscreenState();
}

class _ChangepasswordscreenState extends State<Changepasswordscreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  bool isloading = false;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  Future<void> changePassword(String password) async {
    setState(() {
      isloading = true;
    });
    try {
      final response = await http.post(
        Uri.parse("$BaseUrl/customer/auth/changepassword"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": widget.email, "password": password}),
      );

      if (response.statusCode == 200) {
        CherryToast.success(
          title: Text("Successfully Changed the Password"),
        ).show(context);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } else {
        debugPrint("Error => ${response.statusCode} - ${response.body}");
        final resbody = jsonDecode(response.body);
        CherryToast.error(
          title: Text(resbody["error"]?.toString() ?? "Something went wrong"),
        ).show(context);
      }
    } catch (e) {
      debugPrint("Error => $e");
      CherryToast.error(
        title: Text("Something went wrong. Please try again."),
      ).show(context);
    } finally {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Change Your Password"),
              SizedBox(height: height * 0.02),
              TextFormField(
                controller: newPassword,
                obscureText: obscureNewPassword,
                decoration: InputDecoration(
                  hintText: "New Password",
                  focusedBorder: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureNewPassword = !obscureNewPassword;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter your password";
                  }
                  if (v.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(v)) {
                    return "Include at least one uppercase letter";
                  }
                  if (!RegExp(r'[a-z]').hasMatch(v)) {
                    return "Include at least one lowercase letter";
                  }
                  if (!RegExp(r'[0-9]').hasMatch(v)) {
                    return "Include at least one number";
                  }
                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) {
                    return "Include at least one special character";
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.01),
              TextFormField(
                controller: confirmPassword,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  focusedBorder: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter your password";
                  }
                  if (v != newPassword.text) {
                    return "Password does not match";
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
                  onPressed: isloading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            await changePassword(newPassword.text);
                          }
                        },
                  child: isloading
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(
                          "Change Password",
                          style: TextStyle(color: Colors.white),
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