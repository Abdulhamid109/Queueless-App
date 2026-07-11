import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/WorkerAppbar.dart';
// import 'package:queueless/admin/LoginScreen.dart';
import 'package:queueless/constant/env.dart';
// import 'package:queueless/helper/handleLogoutFunctionality.dart';
import 'package:queueless/worker/workerbookings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cherry_toast/cherry_toast.dart';

class Workerhomescreen extends StatefulWidget {
  const Workerhomescreen({super.key});

  @override
  State<Workerhomescreen> createState() => _WorkerhomescreenState();
}

class _WorkerhomescreenState extends State<Workerhomescreen> {
  bool isSwitched = false;
  String status = "inactive";
  late Future _workerProfile;
  DateTime dateTime = DateTime.now();
  final DateTime today = DateTime.now();
  String wid = "";
  

  Future getWorkerProfileData () async{
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final workerID = decodedToken["wid"];

      final response = await http.get(Uri.parse("$BaseUrl/worker/getProfile/$workerID"),
      headers: {'Content-Type':'application/json'}
      );
      if(response.statusCode==200){
        final resbody = jsonDecode(response.body);
        setState(() {
          debugPrint("Status ${resbody["data"]["WorkStatus"]}");
          status = resbody["data"]["WorkStatus"];
          isSwitched = status == "active";
        });

        return resbody;
      }
       if(response.statusCode!=200){
        throw Exception("Error : StatusCode - ${response.statusCode} , body - ${response.body}");
       }
    } catch (e) {
      print("Error occured! => $e");
    }
  }
  
  Future updateWorkerStatus () async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final wid = decodedToken["wid"];
      final response = await http.put(Uri.parse("$BaseUrl/worker/update-status/$wid"),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        "status":status,
      })
      );

      if(response.statusCode == 200){
        CherryToast.info(
          disableToastAnimation: true,
                  title: const Text(
                    'Updated the worker status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  action: const Text('Toast content description'),
                  inheritThemeColors: true,
                  displayIcon: false,
                  actionHandler: () {},
                  onToastClosed: () {},
                horizontalAlignment: CrossAxisAlignment.start,
        ).show(context);
      }
      if(response.statusCode!=200){
        throw Exception("Error ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error occured => $e");
    }
  }
  
    // DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context,String aboutPageDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(today.year,today.month,today.day));
    if (picked != null && picked != dateTime) {
      setState(() {
        dateTime = picked;
      });
        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerBookingsPage(date: "${dateTime.toLocal()}".split(' ')[0], aboutPage:aboutPageDate)));
    }
  }
  
  
  @override
  void initState() {
    super.initState();
    _workerProfile = getWorkerProfileData();
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1;
    return Scaffold(
      appBar: WorkerAppbar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: height*0.01,),
              // Text("Every morning the status should be changed"),
              // SizedBox(height: height*0.01,),
              FutureBuilder(
                future:_workerProfile ,
                builder: (context, asyncSnapshot) {
                  if(asyncSnapshot.connectionState == ConnectionState.waiting){
                    return Text("Loading Details....");
                  }else if(asyncSnapshot.hasError){
                    return Text("something went wrong!");
                  } else if(asyncSnapshot.hasData){
                    return ListTile(
                    title: Text("Welcome,",style: TextStyle(fontSize: 20),),
                    subtitle: Text("Dear  ${asyncSnapshot.data!["data"]["workerName"]}"),
                  );
                  }
                  return Text("");
                }
              ),

              SizedBox(height: height*0.03,),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Your current work status"),
                      CupertinoSwitch(
                        value: isSwitched,
                        onChanged: (value) async{
                          setState(() {
                            isSwitched = value;
                            debugPrint("Value - $value");
                             status = value ? "active" : "inactive";
                            // isSwitched?{status="active"}:{status:"inactive"};
                            
                          });
                             await updateWorkerStatus();
                        },
                      ),
                      
                    ],
                  ),
                ),
              ),

              SizedBox(height: height*0.01,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Worker's work Status - $status"),
                    IconButton(onPressed: (){
                      if(status=="inactive"){
                        showDialog(context: context, builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.red,
                            title: Text("In-active work status indicates no Customer booking",style: TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,),
                            actions: [
                              OutlinedButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel",style: TextStyle(color: Colors.white),))
                            ],
                          );
                        },);
                      }
                    }, icon: status=="inactive"?Icon(Icons.info_outline,color: Colors.red,):Icon(Icons.info_outline,color: Colors.green,))
                  ],
                )),
              ),


              SizedBox(height: height*0.02,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Worker Management tools",style: TextStyle(fontSize: 17,decoration: TextDecoration.underline),),
              ),

              Expanded(
                child: GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                children: [
                  GestureDetector(
                    onTap: (){
                      String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                      Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerBookingsPage(date: date, aboutPage: "Your Current Day Booking"),));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        child: Center(child: Text("Today's Bookings"),),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      _selectDate(context, "Your cancelled bookings for ${"${dateTime.toLocal()}".split(' ')[0]}");
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        child: Center(child: Text("Cancelled Bookings"),),
                      ),
                    ),
                  ),
                  GestureDetector(
                  // later dealing with this section (low priority)
                    onTap: (){
                      _selectDate(context, "Your Completed bookings for ${"${dateTime.toLocal()}".split(' ')[0]}");
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        child: Center(child: Text("Completed Bookings"),),
                      ),
                    ),
                  ),
                  // Card(
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  //   color: Colors.white,
                  //   child: Center(child: Text("Total revenue"),),
                  // ),
                ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
