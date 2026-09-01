import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:queueless/admin/AdminHomePage.dart';
import 'package:queueless/admin/SignupScreen.dart';
import 'package:queueless/admin/adminforgotpasswordPage.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/worker/workerloginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color background = Color(0xFFF7F8FA);
  static const Color border = Color(0xFFE5E7EB);

  InputDecoration fieldDecoration(
  String label,
  IconData icon, {
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,

    labelStyle: const TextStyle(
      color: textGrey,
      fontSize: 14,
    ),

    prefixIcon: Icon(
      icon,
      color: textGrey,
      size: 20,
    ),

    suffixIcon: suffixIcon,

    filled: true,
    fillColor: Colors.white,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 18,
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: border,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: green,
        width: 1.5,
      ),
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

        SharedPreferences pref =
            await SharedPreferences.getInstance();

        pref.setString("token", decodedbody["token"]);

        print("Token Data => ${decodedbody["token"]}");

        ScaffoldMessenger.of(context)
            .showSnackBar(
              const SnackBar(
                content: Text(
                  "Successfully logged in...redirecting to homepage",
                ),
                duration: Duration(seconds: 1),
              ),
            )
            .closed
            .then(
              (value) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Adminhomepage(),
                ),
              ),
            );
      } else {
        print(
          "Some Error happened with code as "
          "${response.statusCode} => ${response.body}",
        );

        var error = jsonDecode(response.body);

        final messenger = ScaffoldMessenger.of(context);

        messenger.showMaterialBanner(
          MaterialBanner(
            backgroundColor: Colors.red.shade50,
            leading: const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
            ),
            content: Text(
              error["error"] ?? "Something went wrong",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  messenger.hideCurrentMaterialBanner();
                },
                child: const Text(
                  "Dismiss",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

        Future.delayed(const Duration(seconds: 5), () {
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
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                children: [

                  // ------------------------------------------------
                  // BRAND
                  // ------------------------------------------------

                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: green,
                      size: 31,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Queueless",
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: dark,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Business Platform",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textGrey,
                    ),
                  ),

                  const SizedBox(height: 30),



                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.035),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Welcome back",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            color: dark,
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          "Sign in to manage your business.",
                          style: TextStyle(
                            fontSize: 14,
                            color: textGrey,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: fieldDecoration(
                            "Registered Email",
                            Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: fieldDecoration(
                            "Password",
                            Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: textGrey,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>Navigator.push(context, MaterialPageRoute(builder: (context) => AdminForgotpasswordscreen(),)),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: green,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    await handleLogin();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,
                              disabledBackgroundColor:
                                  green.withOpacity(0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 21,
                                    width: 21,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Sign in",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Register
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: textGrey,
                                fontSize: 13.5,
                              ),
                              children: [
                                const TextSpan(
                                  text: "New to Queueless? ",
                                ),
                                TextSpan(
                                  text: "Create an account",
                                  style: const TextStyle(
                                    color: green,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AdminSignupScreen(),
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

                  const SizedBox(height: 22),

                  // ------------------------------------------------
                  // WORKER LOGIN
                  // ------------------------------------------------

                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Workerloginscreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: border,
                        ),
                      ),
                      child: Row(
                        children: [

                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              size: 19,
                              color: dark,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Are you a worker?",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: dark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Sign in to your worker account",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: textGrey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ------------------------------------------------
                  // FOOTER
                  // ------------------------------------------------

                  Text(
                    "Queueless",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Simplifying business. Improving experiences.",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
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