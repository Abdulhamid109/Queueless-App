import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/admin/LoginScreen.dart';
import 'package:queueless/admin/adminOTPPage.dart';
import 'package:queueless/constant/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color background = Color(0xFFF7F8FA);
  static const Color border = Color(0xFFE5E7EB);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,

      labelStyle: const TextStyle(color: textGrey, fontSize: 14),

      prefixIcon: Icon(icon, color: textGrey, size: 20),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
    );
  }

  Future<void> handleSignup() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showError("Please fill in all fields.");
      return;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    if (!emailRegex.hasMatch(emailController.text.trim())) {
      showError("Please enter a valid email address.");
      return;
    }

    final password = passwordController.text;

    if (password.length < 8) {
      showError("Password must be at least 8 characters.");
      return;
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      showError("Password must contain an uppercase letter.");
      return;
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      showError("Password must contain a lowercase letter.");
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      showError("Password must contain a number.");
      return;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      showError("Password must contain a special character.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$BaseUrl/admin/auth/signup"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim().toLowerCase(),
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
              const SnackBar(
                content: Text("Account created successfully."),
                duration: Duration(seconds: 1),
              ),
            )
            .closed
            .then((value) {
              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminLoginScreen(),
                ),
              );
            });
      } else {
        String errorMessage = "Something went wrong.";

        try {
          final decoded = jsonDecode(response.body);

          errorMessage =
              decoded["error"] ??
              decoded["message"] ??
              "Unable to create account.";
        } catch (_) {}

        if (mounted) {
          showError(errorMessage);
        }
      }
    } catch (e) {
      debugPrint("Signup Error => $e");

      if (mounted) {
        showError("Unable to connect to the server.");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool isloading = false;
  void showError(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentMaterialBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.red.shade50,

        leading: const Icon(Icons.error_outline_rounded, color: Colors.red),

        content: Text(
          message,
          style: const TextStyle(fontSize: 13, color: dark),
        ),

        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
            },
            child: const Text(
              "Dismiss",
              style: TextStyle(color: green, fontWeight: FontWeight.w600),
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

  Future<void> handlePreSignup() async {
    setState(() {
      isloading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("name", nameController.text.toString());
      prefs.setString("email", emailController.text.toLowerCase());
      prefs.setString("password", passwordController.text);
      debugPrint("Email => ${emailController.text}");

      final response = await http.post(
        Uri.parse("$BaseUrl/admin/auth/presignup"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.toLowerCase().toString(),
        }),
      );

      if (response.statusCode == 200) {
        CherryToast.success(
          title: Text("Successfully sent the OTP Email"),
        ).show(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminOTPScreen(
              registeredEmail: emailController.text.trim().toString(),
              reason: "signup",
            ),
          ),
        );
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
      print("Something went wrong $e");
    } finally {
      setState(() {
        isloading = false;
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

            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),

              child: Column(
                children: [
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

                      border: Border.all(color: border),

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
                          "Create your account",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            color: dark,
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          "Set up your business account on Queueless.",
                          style: TextStyle(fontSize: 14, color: textGrey),
                        ),

                        const SizedBox(height: 28),

                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: fieldDecoration(
                            "Business Name",
                            Icons.business_outlined,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: fieldDecoration(
                            "Company Email",
                            Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,

                          decoration: fieldDecoration(
                            "Password",
                            Icons.lock_outline_rounded,

                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
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

                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 15,
                              color: textGrey,
                            ),

                            const SizedBox(width: 7),

                            Expanded(
                              child: Text(
                                "Use at least 8 characters with uppercase, lowercase, number and special character.",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  height: 1.4,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 54,

                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    await handlePreSignup();
                                  },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,

                              disabledBackgroundColor: green.withOpacity(0.6),

                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),

                            child: isLoading
                                ? const SizedBox(
                                    height: 21,
                                    width: 21,

                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Create account",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade200),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
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
                              child: Divider(color: Colors.grey.shade200),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: textGrey,
                                fontSize: 13.5,
                              ),

                              children: [
                                const TextSpan(
                                  text: "Already have an account? ",
                                ),

                                TextSpan(
                                  text: "Sign in",
                                  style: const TextStyle(
                                    color: green,
                                    fontWeight: FontWeight.w700,
                                  ),

                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminLoginScreen(),
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

                  const Text(
                    "Queueless",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Simplifying business. Improving experiences.",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
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
