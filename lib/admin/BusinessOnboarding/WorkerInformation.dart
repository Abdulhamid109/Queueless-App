import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:queueless/admin/BusinessOnboarding/serviceInformation.dart';
import 'package:queueless/models/WorkerInformationModal.dart';

class Workerinformation extends StatefulWidget {
  const Workerinformation({super.key});

  @override
  State<Workerinformation> createState() => _WorkerinformationState();
}

class _WorkerinformationState extends State<Workerinformation> {
  TextEditingController workerName = TextEditingController();
  TextEditingController workerEmail = TextEditingController();
  bool isloading = false;
  var workerBox = Hive.box<Workerinformationmodal>("WorkerBox");

  Future <void> onhandleWorkerInformation (bool toggleState)async{
    setState(() {
      isloading = true;
    });
    try {
      if(workerName.text.isEmpty || workerEmail.text.isEmpty){
         return showDialog(
          barrierColor: Colors.black45,
          context: context, builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Kindly enter full values"),
            actions: [
              TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Close"))
            ],
          );
        },);
      }

      Workerinformationmodal workerinfo = Workerinformationmodal(WorkerEmail: workerEmail.text.toString().toLowerCase(), WorkerName: workerName.text.toString());
      if(toggleState){
        workerBox.add(workerinfo).then((value) {
        workerEmail.clear();
        workerName.clear();
      },);
      }else{
        workerBox.add(workerinfo).then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Serviceinformation(),));
      },);
      }
      print("Successfully added the worker!");
      
    } catch (e) {
      throw "Error - WorkerInfoPage => $e";
    }finally{
      setState(() {
        isloading=false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    double width = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Step 02 - Workers Information",
                      textAlign: .center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                subtitle: Opacity(
                  opacity: 0.5,
                  child: Text(
                    "Based on the emails provided workers have to login at the start of the day",
                    textAlign: .center,
                  ),
                ),
              ),
            ),

            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: workerName,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Worker Name",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    TextFormField(
                      controller: workerEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Worker Email",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(15),
                          ),
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          showDialog(
                            // barrierDismissible: false,
                            barrierColor: const Color.fromARGB(190, 0, 0, 0),
                            context: context,
                            builder: (context) {
                              return AlertDialog(

                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: Text(
                                  "Would You like to add More Workers?",
                                  textAlign: .center,
                                  style: TextStyle(fontSize: 15),
                                ),
                                content: SizedBox(
                                  width: width * 0.3,
                                  child: Row(
                                    mainAxisSize: .min,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            backgroundColor: Colors.blue,
                                          ),
                                          onPressed: () {
                                            onhandleWorkerInformation(true).then((value) => Navigator.pop(context),);
                                          },
                                          child: Text(
                                            "Add More",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width*0.01,),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                          onPressed: () {
                                            onhandleWorkerInformation(false);
                                          },
                                          child: Text(
                                            "Next",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        
                        },
                        child: Text(
                          "Add Worker",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}
