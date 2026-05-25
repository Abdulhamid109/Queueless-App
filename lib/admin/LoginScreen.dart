import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:queueless/admin/AdminHomePage.dart';
import 'package:queueless/admin/SignupScreen.dart';
import 'package:queueless/constant/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  static const Color navy = Color(0xFF111827);

  static const Color blue = Color(0xFF2563EB);

  static const Color light = Color(0xFFF8FAFC);

  static const Color border = Color(0xFFE5E7EB);

  static const Color textGrey = Color(0xFF6B7280);

  InputDecoration fieldDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,

      labelStyle: const TextStyle(color: textGrey, fontSize: 14),

      prefixIcon: Icon(icon, color: textGrey),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),

        borderSide: const BorderSide(color: border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),

        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
    );
  }

  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse("$BaseUrl/admin/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.toString().toLowerCase(),
          'password': passwordController.text.toString(),
        }),
      );

      if (response.statusCode == 200) {
        var decodedbody = jsonDecode(response.body);
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("token", decodedbody["token"]);
        print("Token Data => ${decodedbody["token"]}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully logged in...redirecting to homepage"),
            duration: Duration(seconds: 2),
          ),
        ).closed.then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Adminhomepage(),)),);
      } else {
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
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
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
    } catch (e) {
      print("Error => $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Container(
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                color: light,

                borderRadius: BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Center(
                    child: Container(
                      width: 75,
                      height: 75,

                      decoration: BoxDecoration(
                        color: blue.withOpacity(0.1),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: blue,
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Center(
                    child: Text(
                      "Admin Login",

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      "Manage your business dashboard securely",

                      textAlign: TextAlign.center,

                      style: TextStyle(color: textGrey, fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 35),

                  TextFormField(
                    controller: emailController,
                    decoration: fieldDecoration(
                      "Company Email",
                      Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,

                    decoration: fieldDecoration(
                      "Password",

                      Icons.lock_outline,

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },

                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,

                          color: textGrey,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,

                    child: TextButton(
                      onPressed: () {},

                      child: const Text(
                        "Forgot Password?",

                        style: TextStyle(
                          color: blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,

                    height: 55,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: () async {
                        await handleLogin();
                      },

                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : const Text(
                              "Login",

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: textGrey, fontSize: 14),

                        children: [
                          const TextSpan(text: "Don't have an Admin account? "),

                          TextSpan(
                            text: "Register Now",

                            style: const TextStyle(
                              color: blue,
                              fontWeight: FontWeight.bold,
                            ),

                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (context) => AdminSignupScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
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
