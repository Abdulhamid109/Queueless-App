import 'package:flutter/material.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';

class Expensepage extends StatefulWidget {
  const Expensepage({super.key});

  @override
  State<Expensepage> createState() => _ExpensepageState();
}

class _ExpensepageState extends State<Expensepage> {
  DateTime dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1;
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
              SizedBox(height: height*0.01,),
              Text("Know Your Earnings",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: height*0.03,),
              GestureDetector(
                onTap: (){
          
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(child: Text("Daily Earnings (${dateTime.day}/${dateTime.month}/${dateTime.year})")),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height*0.02,),
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(child: Text("search Earnings (based on Date)")),
                  ),
                ),
              ),
              SizedBox(height: height*0.02,),
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(child: Text("Overall Earnings (Total)")),
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