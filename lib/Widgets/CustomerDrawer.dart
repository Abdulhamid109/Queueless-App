import 'package:flutter/material.dart';
import 'package:queueless/Customer/AboutusScreen.dart';
import 'package:queueless/Customer/ContactScreen.dart';
import 'package:queueless/Customer/FeedbackScreen.dart';
import 'package:queueless/Customer/HomeScreen.dart';
import 'package:queueless/Customer/ProfileScreen.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';

class Customerdrawer extends StatefulWidget {
  const Customerdrawer({super.key});

  @override
  State<Customerdrawer> createState() => _CustomerdrawerState();
}

class _CustomerdrawerState extends State<Customerdrawer> {

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        
        children: [
          Container(
            width: double.infinity,
            height: height * 0.25,
            decoration: BoxDecoration(color: Colors.blue.shade100),
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                Icon(Icons.run_circle, size: 40, color: Colors.green),
                Text(
                  "Queueless",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.01),
          ListTile(leading: Icon(Icons.home), title: Text("Home"),onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(),)),),
          ListTile(leading: Icon(Icons.person), title: Text("Profile"),onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => Profilescreen(),)),),
          ListTile(
            leading: Icon(Icons.info_rounded),
            title: Text("About us"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Aboutusscreen(),)),
          ),
          ListTile(leading: Icon(Icons.call), title: Text("Contact"),onTap:()=> Navigator.push(context,MaterialPageRoute(builder: (context) => Contactscreen(),)),
      ),
          ListTile(
            leading: Icon(Icons.message_sharp),
            title: Text("Feedback"),
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => Feedbackscreen(),)),
          ),
          SizedBox(height: height * 0.01),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  onhandleLogout(context);
                },
                child: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
      
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(opacity: 0.5,
            child: Text("All Rights reserved by Queueless Team",style: TextStyle(fontSize: 10),textAlign: TextAlign.center,),),
          )
        ],
      ),
    );
  }
}
