import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';

class BusinessFeedback extends StatefulWidget {
  final String bid;
  const BusinessFeedback({super.key,required this.bid});

  @override
  State<BusinessFeedback> createState() => _BusinessFeedbackState();
}

class _BusinessFeedbackState extends State<BusinessFeedback> {
  List feedbacks = [];
  bool isloading = false;

  Future getAllFeedbacks ()async{
    setState(() {
      isloading=true;
    });
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/Businessfeedbacks/${widget.bid}"),
        headers: {'Content-Type':'application/json'}
      );
      if(response.statusCode==200){
        final resbody = jsonDecode(response.body);
        
        setState(() {
          feedbacks = resbody["data"] ;
        });
      }

      if(response.statusCode!=200){
        debugPrint("Error => ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error => $e");
      throw Exception("error => $e");
    } finally{
      setState(() {
        isloading=false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllFeedbacks();
  }
  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height*1;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              SizedBox(height: height*0.01,),
              Text("Customer's Feedback",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: height*0.03,),

              isloading?
              Center(child: CircularProgressIndicator(),)
              :feedbacks.isEmpty?
              Center(child: Text("No Feedbacks Found!"),)
              :Expanded(
                child: ListView.builder(
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    final data = feedbacks[index];
                    return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(data["Title"]),
                    subtitle: Text(data["Description"]),
                  ),
                ),
              );
                  },),
              )
            
            ],
          ),
        ),
      ),
    );
  }
}