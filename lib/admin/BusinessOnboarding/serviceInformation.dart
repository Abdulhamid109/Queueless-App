import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:queueless/admin/BusinessOnboarding/TimeInformation.dart';
import 'package:queueless/models/serviceInformationModal.dart';

class Serviceinformation extends StatefulWidget {
  const Serviceinformation({super.key});

  @override
  State<Serviceinformation> createState() => _ServiceinformationState();
}

class _ServiceinformationState extends State<Serviceinformation> {
  
  TextEditingController serviceName = TextEditingController();
  TextEditingController serviceDuration = TextEditingController();
  TextEditingController serviceCharge = TextEditingController();
  var serviceBox = Hive.box<Serviceinformationmodal>("ServiceBox");


  Future <void> onhandleServiceInformation (bool toggleState)async{
    try {
      if(serviceName.text.isEmpty || serviceDuration.text.isEmpty || serviceCharge.text.isEmpty){
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

      Serviceinformationmodal ServiceInfo = Serviceinformationmodal(
        serviceName: serviceName.text.toString(), 
        serviceDuration: serviceDuration.text.toString(), 
        serviceCharge: serviceCharge.text.toString());

      if(toggleState){
        serviceBox.add(ServiceInfo).then((value) {
        serviceName.clear();
        serviceDuration.clear();
        serviceCharge.clear();
      },);
      }else{
        serviceBox.add(ServiceInfo).then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Timeinformation()));
      },);
      }
      print("Successfully added the worker!");

    } catch (e) {
      throw "Error (service Information) => $e";
    }
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1;
    double width = MediaQuery.of(context).size.width*1;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  "Step 03 - Service Information",
                  textAlign: .center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: height*0.1,),
        
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: serviceName,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Service Name",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      TextFormField(
                        controller: serviceDuration,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Service Duration(in mins)",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      TextFormField(
                        controller: serviceCharge,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Service Charge",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      
        
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
                                  "Would You like to add More services?",
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
                                            onhandleServiceInformation(true).then((value) => Navigator.pop(context),);
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
                                            onhandleServiceInformation(false);
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
                            "Add Service",
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
      ),
    );
  }
}
