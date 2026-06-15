import 'package:flutter/material.dart';
import 'package:queueless/admin/AdminHomePage.dart';
import 'package:queueless/admin/LoginScreen.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Admindrawer extends StatelessWidget {
  const Admindrawer({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1;
    return Drawer(
      child: Column(
        // mainAxisAlignment: .start,
        children: <Widget>[
          Container(
            height: height*0.2,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
            ),
            child: Center(child: Text("Queueless-Admin")),
          ),
          SizedBox(height: height*0.01,),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => Adminhomepage(),)),
          ),
          ListTile(
            leading: Icon(Icons.business),
            title: Text("Add Business"),
            // onTap: () => ,
          ),
          ListTile(
            leading: Icon(Icons.book_online),
            title: Text("All Bookings"),
            // onTap: () => ,
          ),
          ListTile(
            leading: Icon(Icons.cancel_sharp),
            title: Text("Cancelled Bookings"),
            // onTap: () => ,
          ),
          ListTile(
            leading: Icon(Icons.confirmation_num),
            title: Text("Completed Bookings"),
            // onTap: () => ,
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.red
                ),
                onPressed: ()async{
                  onhandleLogout(context, AdminLoginScreen());
                }, child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Logout",style: TextStyle(color: Colors.white),),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.logout,color: Colors.white,),
                    )
                  ],
                )),
            ),
          )

        ],
      ),
    );
  }
}