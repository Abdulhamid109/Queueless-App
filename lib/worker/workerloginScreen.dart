import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';
import 'package:queueless/worker/workerhomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Workerloginscreen extends StatefulWidget {
  const Workerloginscreen({super.key});

  @override
  State<Workerloginscreen> createState() => _WorkerloginscreenState();
}

class _WorkerloginscreenState extends State<Workerloginscreen> {
  TextEditingController emailController = TextEditingController();

  Future <void> handleLogin ()async{
    try {
      // if(!emailController.text.toString().contains(".com"))
      final response = await http.post(Uri.parse("$BaseUrl/worker/auth/worker-login"),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        "workerEmail":emailController.text.toString().toLowerCase().trim()
      })
      );
      if(response.statusCode==200){
        final resBody = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("token", resBody["token"]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text("Successfully logged"),)),
        );
        // await updateWorkerStatus(emailController.text.toString());
        Navigator.push(context, MaterialPageRoute(builder: (context) => Workerhomescreen(),));

      }

      if(response.statusCode!=200){
        throw Exception("Error => responsebody-${response.body} responseStatus - ${response.statusCode}");
      }
    } catch (e) {
      print("Error => $e");
    }
  }
  
  Future <void> updateWorkerStatus (String email)async{
    try {
      // SharedPreferences preferences = await 
      final response = await http.put(Uri.parse("$BaseUrl/worker/update-status"),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        
        "status":"active"
      })
      );

      if(response.statusCode==200){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Workerhomescreen(),));
      }

      if(response.statusCode!=200){
        debugPrint("Error => ${response.statusCode} -- ${response.body}");
        final resbody = jsonDecode(response.body);
        CherryToast.error(
          title: Text(resbody["error"]),
        );
      }
    } catch (e) {
      debugPrint("Error occured => $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: height*0.1,),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50)),
                color: Colors.blue.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Icon(Icons.lock,color: Colors.white,size: 35,),
                ),
              ),
              SizedBox(height: height*0.02,),
              Text("Worker's Login",style: TextStyle(fontSize: 20),),
              SizedBox(height: height*0.02,),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Tip: Worker has to Daily Login to the application in order start the working slot"),
                ),
              ),

              SizedBox(height: height*.02,),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Worker Email",
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder()
                ),
              ),

              SizedBox(height: height*.02,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.blue
                  ),
                  onPressed: ()async{
                    await handleLogin();
                  }, child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Login",style: TextStyle(color: Colors.white),),
                  )),
              )

            ],
          ),
        ),
      ),
    );
  }
}
