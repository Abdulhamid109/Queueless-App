

  import 'package:flutter/material.dart';
import 'package:queueless/Customer/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> onhandleLogout(context)async{
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove("token")
      .then((value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen(),),(route) => false,),);
    } catch (e) {
      print("Error during logout => $e");
    }
  }