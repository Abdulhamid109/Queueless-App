import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';

class BusinessFeedback extends StatefulWidget {
  const BusinessFeedback({super.key});

  @override
  State<BusinessFeedback> createState() => _BusinessFeedbackState();
}

class _BusinessFeedbackState extends State<BusinessFeedback> {
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

              Expanded(
                child: ListView.builder(
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text("UserName $index"),
                    subtitle: Text("Feedback details"),
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