import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:queueless/constant/env.dart';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

class ServiceEditsPage extends StatefulWidget {
  final String bid;
  const ServiceEditsPage({super.key, required this.bid});

  @override
  State<ServiceEditsPage> createState() => _ServiceEditsPageState();
}

class _ServiceEditsPageState extends State<ServiceEditsPage> {
  bool isloading = false;
  bool updateLoading = false;
  List servicesList = [];
  TextEditingController editServiceName = TextEditingController();
  TextEditingController editServiceCharge = TextEditingController();
  TextEditingController editCustomerDuration = TextEditingController();
  late Future getService;
  Future getAllServices() async {
    setState(() {
      isloading = true;
    });
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/getServiceData/${widget.bid}"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        setState(() {
          servicesList = jsonBody["data"];
        });
        // return jsonBody["data"];
      }
      if(response.statusCode!=200){
        throw Exception("Something went wrong => ${response.body} -- ${response.statusCode}");
      }
    } catch (e) {
      print("error => $e");
      throw "Error => $e";
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  Future getSingleService(String serviceID) async {
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/getSingleService/$serviceID"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonbody = jsonDecode(response.body);
        return jsonbody["data"];
      }
    } catch (e) {
      print("Error => $e");
    }
  }


  Future updateServiceData(String serviceID,String name,int AvgDurationPerCustomer,int ChargesPerService) async {
    setState(() {
      updateLoading = true;
    });
    try {
      // print("🟡Step 1 : Before https");
      final response = await http.put(Uri.parse("$BaseUrl/admin/updateServiceData/$serviceID"),
        headers: {'Content-Type':'application/json'},
        body: jsonEncode({
          "name":editServiceName.text.isEmpty ? name:editServiceName.text.toString(),
          "AvgDurationPerCustomer":editCustomerDuration.text.isEmpty?AvgDurationPerCustomer:int.parse(editCustomerDuration.text.toString()),
          "ChargesPerService":editServiceCharge.text.isEmpty?ChargesPerService:int.parse(editServiceCharge.text.toString())
        })
      );
      
      // print("🟡Step 2 : After https");
      if(response.statusCode==200){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            content: Center(child: Text("Successfully updated the Service Info")))
        );
        // Navigator.pop(context);
      }
      if(response.statusCode!=200){
        throw Exception("response : ${response.body} - ${response.statusCode}");
      }
    } catch (e) {
      print("error => $e");
    } finally{
      setState(() {
        updateLoading=false;
        getAllServices();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllServices();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
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

    if (servicesList.isEmpty) {
      return Scaffold(
        appBar: Adminappbar(),
        drawer: Admindrawer(),
        body: Center(child: Text("No associated services found!")),
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
                title: Text("List of associated services"),
                subtitle: Text("${servicesList.length} service found"),
              ),

              SizedBox(
                height: height,
                child: ListView.builder(
                  itemCount: servicesList.length,
                  itemBuilder: (context, index) {
                    final serviceData = servicesList[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: ListTile(
                          title: Text(serviceData["name"]),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (dialogcontext) {
                                  return AlertDialog(
                                    title: Center(
                                      child: Text("Edit Service Data"),
                                    ),
                                    content: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: FutureBuilder(
                                        future: getSingleService(
                                          serviceData["_id"],
                                        ),
                                        builder: (context, asyncSnapshot) {
                                          if (asyncSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else if (asyncSnapshot.hasError) {
                                            return Center(
                                              child: Text(
                                                "Something went wrong",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            );
                                          } else if (asyncSnapshot.hasData) {
                                            editServiceName.text = asyncSnapshot
                                                .data!["name"]
                                                .toString();
                                            // debugPrint("🟡Debug Data => ${asyncSnapshot.data.toString()}");
                                            editServiceCharge
                                                .text = asyncSnapshot
                                                .data!["AvgDurationPerCustomer"]
                                                .toString();
                                            editCustomerDuration.text =
                                                asyncSnapshot
                                                    .data!["ChargesPerService"]
                                                    .toString();
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                TextField(
                                                  
                                                  controller: editServiceName,
                                                  decoration: InputDecoration(
                                                    labelText: "Service Name",
                                                    enabledBorder:
                                                        OutlineInputBorder(),
                                                    focusedBorder:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.01),
                                                TextField(
                                                  keyboardType: TextInputType.numberWithOptions(),
                                                  controller:
                                                      editCustomerDuration,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Customer duration",
                                                    enabledBorder:
                                                        OutlineInputBorder(),
                                                    focusedBorder:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.01),
                                                TextField(
                                                  keyboardType: TextInputType.numberWithOptions(),
                                                  controller: editServiceCharge,
                                                  decoration: InputDecoration(
                                                    labelText: "Service Charge",
                                                    enabledBorder:
                                                        OutlineInputBorder(),
                                                    focusedBorder:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return Text("");
                                        },
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
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text("Close"),
                                            ),
                                            TextButton(
                                              onPressed: () async{
                                                await updateServiceData(serviceData["_id"],serviceData["name"],serviceData["AvgDurationPerCustomer"],serviceData["ChargesPerService"]).then((value) => Navigator.pop(dialogcontext),);
                                              },
                                              child: updateLoading?Center(child: CircularProgressIndicator(),):Text("Update")
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              "Edit",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
