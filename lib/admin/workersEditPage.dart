import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';

class WorkersEditPage extends StatefulWidget {
  final String bid;
  const WorkersEditPage({super.key,required this.bid});

  @override
  State<WorkersEditPage> createState() => _WorkersEditPageState();
}

class _WorkersEditPageState extends State<WorkersEditPage> {
  bool isloading = false;
  List WorkerList = [];
  TextEditingController editWorkerName = TextEditingController();
  TextEditingController editWorkerEmail = TextEditingController();
  Future getAllWorkers () async{
    setState(() {
      isloading=true;
    });
    try {
      final response = await http.get(Uri.parse("$BaseUrl/admin/getWorkerData/${widget.bid}"),
      headers: {'Content-Type':'application/json'}
      );

      if(response.statusCode==200){
        final jsonbody = jsonDecode(response.body);
        setState(() {
          print("Debug data => ${jsonbody} - ${widget.bid}");
          WorkerList = jsonbody["data"];
        });
        return;
      }
    throw Exception("Status ${response.statusCode}: ${response.body}"); 
    } catch (e,stack) {
      print("Error occured => $e");
      print(stack);
      throw "Error => $e";
    } finally{
      setState(() {
        isloading=false;
      });
    }
  }

  Future getSingleWorkerDetails (String wid) async{
    try {
      final response = await http.get(Uri.parse("$BaseUrl/admin/getSingleWorkerData/$wid"),
      headers: {'Content-Type':'application/json'},
      );

      if(response.statusCode==200){
        final jsonbody = jsonDecode(response.body);
        return jsonbody["data"];
      }
    } catch (e) {
      print("Error => $e");
    }
  }

  Future updateWorkers (String wid,String workerName,String WorkerEmail) async{
    try {
      final response = await http.put(Uri.parse("$BaseUrl/admin/updateWorkerData/$wid"),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        "workerName":editWorkerName.text.isEmpty?workerName:editWorkerName.text,
        "WorkerEmail":editWorkerEmail.text.isEmpty?WorkerEmail:editWorkerEmail.text
      })
      );
      if(response.statusCode==200){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            content: Center(child: Text("Successfully updated the workerInfo Info")))
        );
      }
      throw Exception("response : ${response.body} - ${response.statusCode}");
    
    } catch (e) {
      print("Error => $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllWorkers();
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height*1;
    // final width = MediaQuery.of(context).size.width*1;

if (isloading) {
  return Scaffold(
    appBar: Adminappbar(),
    drawer: Admindrawer(),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Fetching the data"),
          SizedBox(height: 12),
          CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

if (WorkerList.isEmpty) {
  return Scaffold(
    appBar: Adminappbar(),
    drawer: Admindrawer(),
    body: Center(
      child: Text("No associated workers found!"),
    ),
  );
}
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              ListTile(
                title: Text("List of associated workers"),
                subtitle: Text("${WorkerList.length} workers found"),
              ),

              SizedBox(
                height: height,
                child: ListView.builder(
                  itemCount: WorkerList.length,
                  itemBuilder: (context, index) {
                    final workerData = WorkerList[index];
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        child: ListTile(
                          title: Text(workerData["workerName"]),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.blue
                            ),
                            onPressed: (){
                              showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Center(child: Text("Edit Service Data")),
                              content: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: FutureBuilder(
                                  future: getSingleWorkerDetails(workerData["_id"]),
                                  builder: (context, asyncSnapshot) {
                                    if(asyncSnapshot.connectionState==ConnectionState.waiting){
                                      return Center(child: CircularProgressIndicator(),);
                                    }else if(asyncSnapshot.hasError){
                                      return Text("something went wrong",style: TextStyle(color: Colors.red),);
                                    } else if(asyncSnapshot.hasData){
                                      editWorkerEmail.text = asyncSnapshot.data!["WorkerEmail"].toString();
                                      editWorkerName.text = asyncSnapshot.data!["workerName"].toString();
                                      return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextField(
                                          controller: editWorkerName,
                                          decoration: InputDecoration(
                                            labelText: "Worker Name",
                                            enabledBorder: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.01),
                                        TextField(
                                          controller: editWorkerEmail,
                                          decoration: InputDecoration(
                                            labelText: "Worker Email",
                                            enabledBorder: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
                                    );
                                  
                                    }
                                    return Text("");
                                    }
                                ),
                              ),
                              actions: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Close"),
                                      ),
                                      TextButton(
                                        onPressed: () async{
                                          await updateWorkers(workerData["_id"], workerData["workerName"], workerData["WorkerEmail"]).then((val)=>Navigator.pop(context));
                                        },
                                        child: Text("Update"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      
                            }, child: Text("Edit",style: TextStyle(color: Colors.white),)),
                        ),
                      ),
                    );
                  },
                
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}