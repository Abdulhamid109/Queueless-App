import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Expensepage extends StatefulWidget {
  final String bid;
  const Expensepage({super.key, required this.bid});

  @override
  State<Expensepage> createState() => _ExpensepageState();
}

class _ExpensepageState extends State<Expensepage> {
  Future getCurrentDateExpense() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final aid = decodedToken["uid"];
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/dailyexpense/$aid/${widget.bid}"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final resbody = await jsonDecode(response.body);
        debugPrint("Data => ${resbody["data"]?.toString()}");
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              // title: Center(child: Text("Total Earnings of (${dateTime.day}/${dateTime.month}/${dateTime.year})",style: TextStyle(fontSize: 15),)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      "Your Total Earnings for (${dateTime.day}/${dateTime.month}/${dateTime.year})",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    resbody["data"]?.toString()??"checking",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );
      }
      if (response.statusCode != 200) {
        debugPrint("Error ${response.statusCode} - ${response.body}");
        final resbody = jsonDecode(response.body);
      CherryToast.error(
        title: Text(resbody["error"].toString()),
      ).show(context);
      }
    } catch (e) {
      print("Something went wrong! -> $e");
      throw "Error $e";
    }
  }

  Future getOverallExpense() async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final aid = decodedToken["uid"];
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/overallexpense/$aid/${widget.bid}"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final resbody = await jsonDecode(response.body);
        debugPrint("Data => ${resbody["data"]?.toString()}");
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              // title: Center(child: Text("Total Earnings of (${dateTime.day}/${dateTime.month}/${dateTime.year})",style: TextStyle(fontSize: 15),)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      "Your Overall Earnings",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    resbody["data"]?.toString()??"checking",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );
      }
      if (response.statusCode != 200) {
        debugPrint("Error ${response.statusCode} - ${response.body}");
        final resbody = jsonDecode(response.body);
      CherryToast.error(
        title: Text(resbody["error"].toString()),
      ).show(context);
      }
    } catch (e) {
      debugPrint("Error => $e");
    }
  }


  DateTime? selectedDate;

Future<void> pickDateAndFetchExpense() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.black, 
              ),
        ),
        child: child!,
      );
    },
  );

  if (picked == null) return; 

  setState(() {
    selectedDate = picked;
  });

  await getExpenseByDate(picked);
}

Future<void> getExpenseByDate(DateTime date) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final decodedToken = JwtDecoder.decode(token!);
    final aid = decodedToken["uid"];

    final formattedDate =
        "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";

    final response = await http.get(
      Uri.parse(
          "$BaseUrl/admin/customexpense/$aid/${widget.bid}?date=$formattedDate"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final resbody = jsonDecode(response.body);
      debugPrint("Data => ${resbody["data"].toString()}");

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    "Earnings for (${date.day}/${date.month}/${date.year})",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  resbody["data"]?.toString() ?? "checking",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      );
    }
    if (response.statusCode != 200) {
      debugPrint("Error ${response.statusCode} - ${response.body}");
      final resbody = jsonDecode(response.body);
      CherryToast.error(
        title: Text(resbody["error"].toString()),
      ).show(context);
    }
  } catch (e) {
    debugPrint("Error => $e");
  }
}
  DateTime dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: height * 0.01),
              Text(
                "Know Your Earnings",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.03),
              GestureDetector(
                onTap: () async{
                  await getCurrentDateExpense();
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: Text(
                          "Daily Earnings (${dateTime.day}/${dateTime.month}/${dateTime.year})",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async => await pickDateAndFetchExpense(),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: Text("search Earnings (based on Date)"),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: ()async=> await getOverallExpense(),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(child: Text("Overall Earnings (Total)")),
                    ),
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
