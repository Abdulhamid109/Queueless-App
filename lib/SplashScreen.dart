import 'package:flutter/material.dart';
import 'package:queueless/Customer/LoginScreen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF159447);
    final Color lightGreen = const Color(0xFFEAF7EF);
    final Color darkText = const Color(0xFF171717);
    final Color secondaryText = const Color(0xFF777777);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),

          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.queue_rounded,
                      color: primaryGreen,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Text(
                    "Queueless",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween(begin: 0.75, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOut,

                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value.clamp(0.0, 1.0),

                            child: Transform.scale(scale: value, child: child),
                          );
                        },

                        child: Container(
                          height: 220,
                          width: 220,

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),

                            border: Border.all(color: Colors.grey.shade200),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.035),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),

                          padding: const EdgeInsets.all(22),

                          child: Image.asset(
                            "assets/file_000000008ee471fd93c3f86bb8fcc4c7.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        "Skip the wait.",
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                          letterSpacing: -0.7,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Queue smarter with Queueless.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),

                        child: Text(
                          "Join queues digitally, track your position in real time, and arrive when it's your turn.",
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.55,
                            color: secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),

                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Save time. Avoid the crowd.",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
