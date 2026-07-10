import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:queueless/constant/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  Future getAdminDetails() async{
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final token = preferences.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final uid = decodedToken["uid"];
      final response = await http.get(Uri.parse("$BaseUrl/admin/adminProfile/$uid"),
      headers: {'Content-Type':'application/json'}
      );

      if(response.statusCode==200){
        final resbody = jsonDecode(response.body);
        return resbody["data"];
      }

      if(response.statusCode!=200){
        throw Exception("Error => ${response.statusCode} -- ${response.body}");
      }

    } catch (e) {
      print("Error => $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAdminDetails();
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: Center(
        child: Text("Admin Profile Page"),
      ),
    );
  }
}