import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:queueless/admin/AdminHomePage.dart';
import 'package:queueless/admin/LoginScreen.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  late Future admindetails;
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
        // debugPrint("Data => ${resbody["data"]}");
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
    admindetails = getAdminDetails();
  }




  @override
  Widget build(BuildContext context) {
      double height = MediaQuery.of(context).size.height*1;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height*0.02,),
            Text("Personal Data",style: TextStyle(fontSize: 20),),
            SizedBox(height: height*0.02,),

            FutureBuilder(
              future: admindetails,
              builder: (context, asyncSnapshot) {
                if(asyncSnapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }
                else if(asyncSnapshot.hasError){
                  return Text("Something went wrong!");
                }else if(asyncSnapshot.hasData){
                  return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person),),
                          title: Text(asyncSnapshot.data!["name"].toString()),
                          subtitle: Text("role"),
                        ),
                    
                        // Divider(thickness: 0.2,),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.email),),
                          title: Text("Email",),
                          subtitle: Text(asyncSnapshot.data!["email"].toString()),
                        ),
                        SizedBox(height: height*0.01,),
                    
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.lightBlue.shade300
                          ),
                          onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => Adminhomepage(),)), 
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.business,color: Colors.white,),
                            Text("Associated businesses",style: TextStyle(color: Colors.white,),),
                          ],
                        )),
                        SizedBox(height: height*0.01,),
                        
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.red
                          ),
                          onPressed: ()async{
                            await onhandleLogout(context, AdminLoginScreen());
                          }, 
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.logout,color: Colors.white,),
                            Text("Logout",style: TextStyle(color: Colors.white,),),
                          ],
                        )),
                      ],
                    ),
                  ),
                );
              
                }
                return Text("");
                }
            )


          ],
        ),
      ),
    );
  }
}