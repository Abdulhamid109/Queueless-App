import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queueless/Widgets/WorkerAppbar.dart';

class Workerhomescreen extends StatefulWidget {
  const Workerhomescreen({super.key});

  @override
  State<Workerhomescreen> createState() => _WorkerhomescreenState();
}

class _WorkerhomescreenState extends State<Workerhomescreen> {
  bool isSwitched = false;
    String status = "inactive";
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
              ListTile(
                title: Text("Welcome,",style: TextStyle(fontSize: 20),),
                subtitle: Text("Dear  Worker"),
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
                        onChanged: (value) {
                          setState(() {
                            isSwitched = value;
                            debugPrint("Value - $value");
                             status = value ? "active" : "inactive";
                            // isSwitched?{status="active"}:{status:"inactive"};
                          });
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      child: Center(child: Text("Today's Bookings"),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      child: Center(child: Text("Cancelled Bookings"),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      child: Center(child: Text("Search Bookings"),),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Colors.white,
                    child: Center(child: Text("Total revenue"),),
                  ),
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
