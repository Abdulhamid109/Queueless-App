import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:queueless/admin/SignupScreen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() =>
      _AdminLoginScreenState();
}

class _AdminLoginScreenState
    extends State<AdminLoginScreen> {

  bool obscurePassword = true;

  static const Color navy =
      Color(0xFF111827);

  static const Color blue =
      Color(0xFF2563EB);

  static const Color light =
      Color(0xFFF8FAFC);

  static const Color border =
      Color(0xFFE5E7EB);

  static const Color textGrey =
      Color(0xFF6B7280);

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
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide: const BorderSide(
          color: border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),

        borderSide: const BorderSide(
          color: blue,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(


      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(24),

            child: Container(

              padding:
                  const EdgeInsets.all(28),

              decoration: BoxDecoration(

                color: light,

                borderRadius:
                    BorderRadius.circular(28),

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

                crossAxisAlignment:
                    CrossAxisAlignment.start,

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

                      style: TextStyle(
                        color: textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  TextFormField(

                    decoration: fieldDecoration(
                      "Company Email",
                      Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextFormField(

                    obscureText: obscurePassword,

                    decoration: fieldDecoration(

                      "Password",

                      Icons.lock_outline,

                      suffixIcon: IconButton(

                        onPressed: () {

                          setState(() {

                            obscurePassword =
                                !obscurePassword;
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

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor: blue,

                        elevation: 0,

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: () {},

                      child: const Text(

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

                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 14,
                        ),

                        children: [

                          const TextSpan(
                            text:
                                "Don't have an Admin account? ",
                          ),

                          TextSpan(

                            text: "Register Now",

                            style: const TextStyle(
                              color: blue,
                              fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }
}