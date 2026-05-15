import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:queueless/Customer/LoginScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  static const Color navy = Color(0xFF1A1A2E);
  static const Color cream = Color(0xFFF5F0EB);
  static const Color gold = Color(0xFFC9A96E);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E1D8);
  static const Color mutedText = Color(0xFF8A7E72);

  InputDecoration _fieldDecoration(
    String label,
    IconData prefix, {
    IconData? suffix,
    VoidCallback? onSuffixTap,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: mutedText,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        color: gold,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
      prefixIcon: Icon(prefix, color: mutedText, size: 20),
      suffixIcon: suffix != null
          ? GestureDetector(
              onTap: onSuffixTap,
              child: Icon(suffix, color: mutedText, size: 20),
            )
          : null,
      filled: true,
      fillColor: fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: navy,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "WELCOME ",
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Create your account",
                    style: TextStyle(
                      color: cream,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: _fieldDecoration(
                            "Full_Name",
                            Icons.person,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Enter your full Name";
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: _fieldDecoration(
                            "Email address",
                            Icons.mail_outline_rounded,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Enter your email";
                            if (!v.contains('@')) return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          obscureText: _obscurePassword,
                          decoration: _fieldDecoration(
                            "Password",
                            Icons.lock_outline_rounded,
                            suffix: _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixTap: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Enter your password";
                            if (v.length < 8) return "Password must be at least 8 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navy,
                              foregroundColor: cream,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: const [
                            Expanded(child: Divider(color: Color(0xFFE0D8CF))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "or continue with",
                                style: TextStyle(
                                  color: mutedText,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFFE0D8CF))),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(child: _socialButton("G", "Google")),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 12, color: mutedText),
                              children: [
                                TextSpan(text: "Already have an account? "),
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                  ..onTap = (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
                                  }
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
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String letter, String label, {IconData? icon}) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4A4A4A),
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null
              ? Icon(icon, size: 16, color: const Color(0xFF4A4A4A))
              : Text(
                  letter,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
