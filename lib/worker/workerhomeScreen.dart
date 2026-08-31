import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/WorkerAppbar.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/worker/workerbookings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cherry_toast/cherry_toast.dart';

class Workerhomescreen extends StatefulWidget {
  const Workerhomescreen({super.key});

  @override
  State<Workerhomescreen> createState() => _WorkerhomescreenState();
}

class _WorkerhomescreenState extends State<Workerhomescreen> {
  bool isSwitched = false;
  String status = "inactive";

  late Future _workerProfile;

  DateTime dateTime = DateTime.now();
  final DateTime today = DateTime.now();

  String wid = "";

  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color background = Color(0xFFF7F8FA);
  static const Color border = Color(0xFFE5E7EB);

  Future getWorkerProfileData() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      final token = pref.getString("token");

      final decodedToken = JwtDecoder.decode(token!);

      final workerID = decodedToken["wid"];

      final response = await http.get(
        Uri.parse("$BaseUrl/worker/getProfile/$workerID"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final resbody = jsonDecode(response.body);

        setState(() {
          status = resbody["data"]["WorkStatus"];
          isSwitched = status == "active";
        });

        return resbody;
      }

      if (response.statusCode != 200) {
        throw Exception(
          "Error : StatusCode - ${response.statusCode} , body - ${response.body}",
        );
      }
    } catch (e) {
      print("Error occured! => $e");
    }
  }

  Future updateWorkerStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final decodedToken = JwtDecoder.decode(token!);

      final wid = decodedToken["wid"];

      final response = await http.put(
        Uri.parse("$BaseUrl/worker/update-status/$wid"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"status": status}),
      );

      if (response.statusCode == 200) {
        CherryToast.info(
          disableToastAnimation: true,
          title: const Text(
            'Updated the worker status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          action: const Text('Toast content description'),
          inheritThemeColors: true,
          displayIcon: false,
          actionHandler: () {},
          onToastClosed: () {},
          horizontalAlignment: CrossAxisAlignment.start,
        ).show(context);
      }

      if (response.statusCode != 200) {
        throw Exception("Error ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error occured => $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _workerProfile = getWorkerProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: WorkerAppbar(),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: _workerProfile,

                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                      ),

                      child: const Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: green,
                            ),
                          ),

                          SizedBox(width: 12),

                          Text(
                            "Loading your profile...",
                            style: TextStyle(fontSize: 13, color: textGrey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (asyncSnapshot.hasError) {
                    return Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100),
                      ),

                      child: const Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 20,
                          ),

                          SizedBox(width: 10),

                          Text(
                            "Something went wrong!",
                            style: TextStyle(color: dark, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  if (asyncSnapshot.hasData) {
                    return Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(color: border),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          Container(
                            height: 52,
                            width: 52,

                            decoration: BoxDecoration(
                              color: green.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: green,
                              size: 27,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome back,",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textGrey,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  "${asyncSnapshot.data!["data"]["workerName"]}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: dark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),

              const SizedBox(height: 24),

              const Text(
                "Work status",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: dark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Control whether customers can book your services.",
                style: TextStyle(fontSize: 12.5, color: textGrey),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(color: border),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.025),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,

                      decoration: BoxDecoration(
                        color: isSwitched
                            ? green.withOpacity(0.10)
                            : Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(13),
                      ),

                      child: Icon(
                        isSwitched
                            ? Icons.work_outline_rounded
                            : Icons.work_off_outlined,

                        color: isSwitched ? green : textGrey,

                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            isSwitched
                                ? "You're currently active"
                                : "You're currently inactive",

                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: dark,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Container(
                                height: 7,
                                width: 7,

                                decoration: BoxDecoration(
                                  color: isSwitched ? green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              const SizedBox(width: 6),

                              Text(
                                isSwitched
                                    ? "Accepting customer bookings"
                                    : "Not accepting bookings",

                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    CupertinoSwitch(
                      value: isSwitched,

                      activeColor: green,

                      onChanged: (value) async {
                        setState(() {
                          isSwitched = value;

                          debugPrint("Value - $value");

                          status = value ? "active" : "inactive";
                        });

                        await updateWorkerStatus();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              InkWell(
                borderRadius: BorderRadius.circular(14),

                onTap: () {
                  if (status == "inactive") {
                    showDialog(
                      context: context,

                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          title: Row(
                            children: [
                              Container(
                                height: 38,
                                width: 38,

                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(11),
                                ),

                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.red,
                                  size: 21,
                                ),
                              ),

                              const SizedBox(width: 12),

                              const Expanded(
                                child: Text(
                                  "Inactive status",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: dark,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          content: const Text(
                            "An inactive work status means customers cannot make bookings with you.",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: textGrey,
                            ),
                          ),

                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              child: const Text(
                                "Got it",
                                style: TextStyle(
                                  color: green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 13,
                  ),

                  decoration: BoxDecoration(
                    color: isSwitched
                        ? green.withOpacity(0.05)
                        : Colors.red.withOpacity(0.04),

                    borderRadius: BorderRadius.circular(14),

                    border: Border.all(
                      color: isSwitched
                          ? green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                    ),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        isSwitched
                            ? Icons.check_circle_outline
                            : Icons.info_outline_rounded,

                        color: isSwitched ? green : Colors.red,

                        size: 18,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          isSwitched
                              ? "Your work status is active."
                              : "Inactive status means no customer bookings.",

                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSwitched ? green : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Worker management",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: dark,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Manage your daily customer bookings.",
                style: TextStyle(fontSize: 12.5, color: textGrey),
              ),

              const SizedBox(height: 14),

              InkWell(
                borderRadius: BorderRadius.circular(20),

                onTap: () {
                  String date =
                      "${dateTime.day}/${dateTime.month}/${dateTime.year}";

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) => WorkerBookingsPage(
                        date: date,
                        aboutPage: "Your Current Day Booking",
                      ),
                    ),
                  );
                },

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(color: border),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.025),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,

                        decoration: BoxDecoration(
                          color: green.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: const Icon(
                          Icons.calendar_today_outlined,
                          color: green,
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Bookings",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: dark,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "View and manage your current day bookings.",
                              style: TextStyle(fontSize: 12, color: textGrey),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 34,
                        width: 34,

                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: Column(
                  children: [
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
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
