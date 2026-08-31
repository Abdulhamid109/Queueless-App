import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';
import 'package:queueless/worker/workerhomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Workerloginscreen extends StatefulWidget {
  const Workerloginscreen({super.key});

  @override
  State<Workerloginscreen> createState() => _WorkerloginscreenState();
}

class _WorkerloginscreenState extends State<Workerloginscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color background = Color(0xFFF7F8FA);
  static const Color border = Color(0xFFE5E7EB);

  InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,

      labelStyle: const TextStyle(color: textGrey, fontSize: 14),

      prefixIcon: Icon(icon, color: textGrey, size: 20),

      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 48),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Enter your worker email";
    }

    final email = value.trim();

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+'
      r'@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    if (!emailRegex.hasMatch(email)) {
      return "Enter a valid email address";
    }

    return null;
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$BaseUrl/worker/auth/worker-login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "workerEmail": emailController.text.trim().toLowerCase(),
        }),
      );

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);

        final SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", resBody["token"]);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("Successfully logged in")),
            duration: Duration(seconds: 1),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Workerhomescreen()),
        );
      } else {
        String errorMessage =
            "Worker account not found. Kindly contact your respective business admin.";

        try {
          final decoded = jsonDecode(response.body);

          errorMessage = decoded["error"] ?? decoded["message"] ?? errorMessage;
        } catch (_) {}

        if (!mounted) return;

        CherryToast.error(
          title: Text(errorMessage, style: const TextStyle(fontSize: 13)),
        ).show(context);
      }
    } catch (e) {
      debugPrint("Worker Login Error => $e");

      if (!mounted) return;

      CherryToast.error(
        title: const Text("Unable to connect to the server. Please try again."),
      ).show(context);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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
                    "Worker Platform",
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

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Worker sign in",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: dark,
                            ),
                          ),

                          const SizedBox(height: 7),

                          const Text(
                            "Sign in to manage your queue and working slot.",
                            style: TextStyle(
                              fontSize: 14,
                              color: textGrey,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 25),

                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: green.withOpacity(0.06),

                              borderRadius: BorderRadius.circular(14),

                              border: Border.all(
                                color: green.withOpacity(0.15),
                              ),
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Container(
                                  height: 34,
                                  width: 34,

                                  decoration: BoxDecoration(
                                    color: green.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    color: green,
                                    size: 19,
                                  ),
                                ),

                                const SizedBox(width: 11),

                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Daily login required",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: dark,
                                        ),
                                      ),

                                      SizedBox(height: 3),

                                      Text(
                                        "Workers need to log in daily to start their working slot.",
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          height: 1.4,
                                          color: textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          

                          TextFormField(
                            controller: emailController,

                            keyboardType: TextInputType.emailAddress,

                            textInputAction: TextInputAction.done,

                            autofillHints: const [AutofillHints.email],

                            decoration: fieldDecoration(
                              "Enter your registered email",
                              Icons.email_outlined,
                            ),

                            validator: validateEmail,

                            onFieldSubmitted: (_) {
                              if (!isLoading) {
                                handleLogin();
                              }
                            },
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 54,

                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleLogin,

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
                                      "Sign in",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),


                          ],
                      ),
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
