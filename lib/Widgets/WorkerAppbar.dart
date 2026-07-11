import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/admin/LoginScreen.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';
// import 'package:queueless/worker/workerloginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerAppbar extends StatefulWidget implements PreferredSizeWidget{
  const WorkerAppbar({super.key});

  @override
  State<WorkerAppbar> createState() => _WorkerAppbarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _WorkerAppbarState extends State<WorkerAppbar> {


  Future <void> onhandleWorkerLogout ()async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final wid = decodedToken["wid"];
      final response = await http.put(Uri.parse("$BaseUrl/worker/update-status/$wid"),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        "status":"inactive",
      })
      );

      if(response.statusCode == 200){
        CherryToast.info(
          disableToastAnimation: true,
                  title: const Text(
                    'Successfully logged out!',
                  ),
                  
        ).show(context);
        await onhandleLogout(context, AdminLoginScreen());
      }
      if(response.statusCode!=200){
        throw Exception("Error ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error occured => $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue.shade100,
      title: Text("Worker Panel"),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.red
                            ),
            onPressed: (){
            showDialog(
              barrierDismissible: false,
              context: context, builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("Are you sure you want to logout?",style: TextStyle(fontSize: 18),textAlign: TextAlign.center,),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.red,
                    
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text("Tip : Once you logout your session will be inactive and all the customer will be at halt",style: TextStyle(color: Colors.white,fontSize: 14),)),
                      )),
                  ],
                                  ),
                  actions: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.grey.shade300
                            ),
                            onPressed: ()=>Navigator.pop(context), child: Text("Cancel")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.red
                            ),
                      onPressed: ()async{
                        // await onhandleLogout(context, Workerloginscreen());
                        await onhandleWorkerLogout();
                      }, child: Text("Logout",style: TextStyle(color: Colors.white),))
                        ],
                      ),
                    )
                  ],
                );
          
            },);
          }, child: Text("Logout",style: TextStyle(color: Colors.white),)),
        )
      
      ],
    );
  }
}