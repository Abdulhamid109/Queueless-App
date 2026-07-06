import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/socketservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Queuescreen extends StatefulWidget {
  final String bid;
  final String bname;
  final String baddress;
  const Queuescreen({
    super.key,
    required this.bid,
    required this.bname,
    required this.baddress,
  });

  @override
  State<Queuescreen> createState() => _QueuescreenState();
}

class _QueuescreenState extends State<Queuescreen> {
  Future<Map<String, dynamic>>? TimeDetails;
  TextEditingController titleController = TextEditingController();
  TextEditingController decriptionController = TextEditingController();
  SocketService socketIO = SocketService();
  // bool? isServiceSelected = false;
  // int? selectedIndex;
  Set<int> selectedIndex = {};
  List serviceIds = [];
  List allworkers = [];

  Future<Map<String, dynamic>> getTimeData() async {
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/getTimeData/${widget.bid}"),
        headers: {'Content-Type': 'application/json'},
      );

      final responsBody = await jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responsBody["data"] == null) {
          throw Exception("data field is null in response");
        }
        return responsBody["data"] as Map<String, dynamic>;
      }
      throw Exception(
        "Couldn't get the time details => ${response.body} : ${response.statusCode}",
      );
    } catch (e) {
      print("Error => $e");
      throw "Error => $e";
    }
  }

  bool _isRefreshing = false;

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
      TimeDetails = getTimeData();
    });
    await TimeDetails;
    setState(() => _isRefreshing = false);
  }

  List allServiceDetails = [];
  bool serviceDetailsLoading = false;
  bool loadedDetails = false;
  bool queuePresency = false;
  String EWT = "";
  String Postion = "";


  Future getRealtimeQueueUpdates() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final qid = prefs.getString("queueId-${widget.bid}");
      if (qid == null || qid.isEmpty) return;

      debugPrint("🟡we are here! => ${qid}");


      final response = await http.get(
        Uri.parse("$BaseUrl/customer/getTotalQueueCount/$qid"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint("🟡and we are here!");
        final resbody = jsonDecode(response.body);
        debugPrint("QueueData => ${resbody["data"]["expectedStartTime"]}");
        setState(() {
          DateTime parsedDate = DateTime.parse(resbody["data"]["expectedStartTime"]);
          String formatted = DateFormat("dd MMM yyyy, hh:mm a").format(parsedDate);
          queuePresency=true;
          EWT = formatted;
          Postion = resbody["data"]["CurrentPostion"].toString();
        });
        
      }

      if (response.statusCode != 200) {
        debugPrint("🟡 Error => ${response.body} -- ${response.statusCode}");
      }
    } catch (e) {
      print("Error => $e");
    }
  }

  Future<void> getServices() async {
    setState(() {
      serviceDetailsLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/getServiceData/${widget.bid}"),
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          allServiceDetails = responseBody["data"];
        });
      }
    } catch (e) {
      print("Error => $e");
    } finally {
      setState(() {
        loadedDetails = true;
        serviceDetailsLoading = false;
      });
    }
  }

  Future joinQueue() async {
    try {
      debugPrint("Started");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedData = JwtDecoder.decode(token!);
      final cid = decodedData["uid"];
      final response = await http.post(
        Uri.parse("$BaseUrl/customer/joinQueue/${widget.bid}/$cid"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"serviceIds": allServiceDetails}),
      );

      if (response.statusCode == 200) {
        _joinUserRoom(cid);
        // socketIO.on("queue-estimated-time", (data) {
        //   debugPrint("The Estimated waiting time for the worker is => $data");
        // });
        // debugPrint("In between");
        final resbody = jsonDecode(response.body);
        final qid = resbody["data"];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("queueId-${widget.bid}", qid);
        await getRealtimeQueueUpdates();
        Navigator.pop(context);
        //store the estimation time in the sharedpref
        // an socket instance we will be gettign here
      }

      if (response.statusCode != 200) {
        debugPrint("Error -> ${response.statusCode} -- ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Center(child: Text("${jsonDecode(response.body)["error"]}",style: TextStyle(color: Colors.white),)))
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error => $e");
    }
  }

  Future<void> addBusinessFeedback() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedTokenData = JwtDecoder.decode(token!);
      final uid = decodedTokenData["uid"];
      final response = await http.post(
        Uri.parse("$BaseUrl/customer/addServiceFeedback/${widget.bid}/$uid"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "Title": titleController.text.toString(),
          "Description": decriptionController.text.toString(),
        }),
      );
      if (response.statusCode == 200) {
        titleController.clear();
        decriptionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text("Successfully submited the feedback")),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
      if (response.statusCode != 200) {
        print("Error => ${response.body} - ${response.statusCode}");
        final decodedError = jsonDecode(response.body);
        // print(decodedError["error"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(decodedError["error"])),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("Failed to perform the functionality => $e");
      throw "Error => $e";
    }
  }

  void _registerListeners() {
    socketIO.off("workerQueueUpdated");
    socketIO.on("workerQueueUpdated", (data) {
      debugPrint("🟡 received => $data"); // this fires AFTER the API call below
      setState(() {
        // update your UI with data
      });
    });
  }

  void _joinBusinessRoom() {
    socketIO.onceConnected(() {
      socketIO.emit("JoinBusiness", widget.bid);
      debugPrint("Emitted JoinBusiness with bid: ${widget.bid}");
      getRealtimeQueueUpdates();
    });
  }

  void _joinUserRoom(String uid) async {
    socketIO.onceConnected(() {
      socketIO.emit("JoinUser", uid);
      debugPrint("Emitted the user with uid as $uid");
    });
  }

  Future getAllWorkers() async {
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/getWorkerData/${widget.bid}"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final resbody = jsonDecode(response.body);
        setState(() {
          allworkers = resbody["data"];
        });
      }

      if (response.statusCode != 200) {
        throw Exception("Error => ${response.statusCode} -- ${response.body}");
      }
    } catch (e) {
      debugPrint("error => $e");
    }
  }

  @override
  void initState() {
    super.initState();
    TimeDetails = getTimeData();
    socketIO.init(serverUrl: BaseUrl);
    _joinBusinessRoom();
    _registerListeners();
    getAllWorkers();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    double width = MediaQuery.of(context).size.width * 1;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: Customerappbar(),
        drawer: Customerdrawer(),
        body: RefreshIndicator(
          onRefresh: () => getTimeData(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Text("BUSINESS", style: TextStyle(fontSize: 20)),
                  ),
                  SizedBox(height: height * 0.02),

                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("DETAILS"),
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          ListTile(
                            title: Text("Business Name"),
                            subtitle: Text(widget.bname),
                            leading: Opacity(
                              opacity: 0.5,
                              child: Icon(Icons.business),
                            ),
                          ),
                          Divider(thickness: 0.3),
                          ListTile(
                            title: Text("Business Address"),
                            subtitle: Text(widget.baddress),
                            leading: Opacity(
                              opacity: 0.5,
                              child: Icon(Icons.location_pin),
                            ),
                          ),
                          Divider(thickness: 0.3),

                          FutureBuilder<Map<String, dynamic>>(
                            future: TimeDetails,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: Text("Loading additional details..."),
                                );
                              }
                              if (snapshot.hasError) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Something's Off... Try again later"),
                                    GestureDetector(
                                      onTap: _isRefreshing ? null : _refresh,
                                      child: AnimatedRotation(
                                        turns: _isRefreshing ? 1.0 : 0.0,
                                        duration: Duration(milliseconds: 600),
                                        child: Icon(
                                          Icons.refresh,
                                          color: Color(0xFFC9A96E),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text("Opening Time"),
                                      subtitle: Text(
                                        snapshot.data!["BST"].toString(),
                                      ),
                                      leading: Opacity(
                                        opacity: 0.5,
                                        child: Icon(Icons.punch_clock),
                                      ),
                                    ),
                                    Divider(thickness: 0.3),
                                    ListTile(
                                      title: Text("Closing Time"),
                                      subtitle: Text(
                                        snapshot.data!["BET"].toString(),
                                      ),
                                      leading: Opacity(
                                        opacity: 0.5,
                                        child: Icon(Icons.punch_clock),
                                      ),
                                    ),
                                    Divider(thickness: 0.3),
                                    ListTile(
                                      title: Text("Total Customer Limit"),
                                      subtitle: Text(
                                        snapshot.data!["CustomerLimitPerDay"]
                                            .toString(),
                                      ),
                                      leading: Opacity(
                                        opacity: 0.5,
                                        child: Icon(Icons.person),
                                      ),
                                    ),
                                    Divider(thickness: 0.3),
                                  ],
                                );
                              }

                              return Text("");
                            },
                          ),

                          ListTile(
                            title: Text("Website"),
                            leading: Opacity(
                              opacity: 0.5,
                              child: Icon(Icons.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Opacity(opacity: 0.5, child: Text("Queue")),

                              Text(
                                "Disconnected",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),

                        Divider(thickness: 0.3),
                        SizedBox(height: height * 0.01),
                        allworkers.isEmpty?
                        Column(
                          children: [
                            Text("Loading"),
                            CircularProgressIndicator(color: Colors.blue,)
                          ],
                        ):Text("Worker & Queue status"),
                        // SizedBox(height: height * 0.01),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: allworkers.length==1?height*0.125:height*0.25,
                            width: height*0.5,
                            child: ListView.builder(
                              itemCount: allworkers.length,
                              itemBuilder: (context, index) {
                                final workers = allworkers[index];
                                // debugPrint("Wokrers $workers");
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  color: workers["WorkStatus"]=="inactive"?Colors.red.shade100:Colors.green.shade100,
                                  child: ListTile(
                                    leading: CircleAvatar(child: Icon(Icons.person)),
                                    title: Text(workers["workerName"]),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Total Customers : ${workers["queueInfo"].length}"),
                                        Text("Status : ${workers["WorkStatus"]}")
                                      ],
                                    ),
                                  )
                                ),
                                );
                            
                              },
                              ),
                          ),
                        ),
                        queuePresency?
                        Column(
                          children: [
                        SizedBox(height: height*0.01,),
                            Text("You're enrolled in Queue"),
                        SizedBox(height: height*0.01,),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Current Postion : $Postion"),
                                SizedBox(height: height*0.01,),
                                Text("Expected Time : $EWT"),
                              ],
                            ),
                          ),
                        ),
                          ],
                        ):Text(""),

                          Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10,
                                                      ),
                                                ),
                                                backgroundColor: Colors.black,
                                              ),
                                              onPressed: () async {
                                                await getServices();
                                                if (!loadedDetails ||
                                                    serviceDetailsLoading) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Loading service details kindly wait",
                                                      ),
                                                    ),
                                                  );
                                                }
                                                showDialog(
                                                  barrierColor:
                                                      Colors.black26,
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder: (context, setState) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                          title: Text(
                                                            "Select a Service",
                                                          ),
                                                          content: SizedBox(
                                                            height:
                                                                height * 0.5,
                                                            width:
                                                                width * 0.8,
                                                            child:
                                                                allServiceDetails
                                                                    .isEmpty
                                                                ? Center(
                                                                    child: CircularProgressIndicator(
                                                                      color: Color(
                                                                        0xFFC9A96E,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : ListView.builder(
                                                                    itemCount:
                                                                        allServiceDetails
                                                                            .length,
                                                            
                                                                    itemBuilder:
                                                                        (
                                                                          context,
                                                                          index,
                                                                        ) {
                                                                          final data =
                                                                              allServiceDetails[index];
                                                                          final isSelected = selectedIndex.contains(
                                                                            index,
                                                                          );
                                                                          return ListTile(
                                                                            title: Text(
                                                                              data["name"],
                                                                            ),
                                                                            subtitle: Text(
                                                                              "${data["AvgDurationPerCustomer"]} min · ₹${data["ChargesPerService"]}",
                                                                            ),
                                                                            trailing: ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10,
                                                                                  ),
                                                                                ),
                                                                                backgroundColor: Colors.blue,
                                                                              ),
                                                                              onPressed: () {
                                                                                setState(
                                                                                  () {
                                                                                    if (isSelected) {
                                                                                      selectedIndex.remove(
                                                                                        index,
                                                                                      );
                                                                                      setState(
                                                                                        () {
                                                                                          serviceIds.remove(
                                                                                            data["_id"],
                                                                                          );
                                                                                        },
                                                                                      );
                                                                                    } else {
                                                                                      selectedIndex.add(
                                                                                        index,
                                                                                      );
                                                                                      serviceIds.add(
                                                                                        data["_id"],
                                                                                      );
                                                                                    }
                                                                                    print(
                                                                                      "Selected indices: $selectedIndex",
                                                                                    );
                                                            
                                                                                    print(
                                                                                      "Selected Ids => $serviceIds",
                                                                                    );
                                                                                  },
                                                                                );
                                                                              },
                                                                              child: Text(
                                                                                isSelected
                                                                                    ? "Selected "
                                                                                    : "Select",
                                                                                style: TextStyle(
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () {
                                                                              Border(
                                                                                bottom: BorderSide(
                                                                                  color: Colors.black,
                                                                                ),
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                  ),
                                                          ),
                                                          actions: [
                                                            serviceIds
                                                                    .isNotEmpty
                                                                ? TextButton(
                                                                    onPressed: () async {
                                                                      if (serviceIds.length >
                                                                          2) {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                        final messenger = ScaffoldMessenger.of(
                                                                          context,
                                                                        );
                                                                        messenger.showMaterialBanner(
                                                                          MaterialBanner(
                                                                            backgroundColor: Colors.red,
                                                                            content: Text(
                                                                              "Only 2 services can be selected at a Time",
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                            actions: [
                                                                              ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.black,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      10,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                            
                                                                                onPressed: () {
                                                                                  messenger.hideCurrentMaterialBanner();
                                                                                },
                                                                                child: Text(
                                                                                  "Close",
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                        Future.delayed(
                                                                          Duration(
                                                                            seconds: 5,
                                                                          ),
                                                                          () {
                                                                            if (messenger.mounted) {
                                                                              messenger.hideCurrentMaterialBanner();
                                                                            }
                                                                          },
                                                                        );
                                                                      } else {
                                                                        await joinQueue();
                                                                        // Navigator.pop(context);
                                                                      }
                                                                    },
                                                                    child: Text(
                                                                      "Join Queue",
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    "Select service",
                                                                  ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                  color: Color(
                                                                    0xFF8A7E72,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_circle_outline,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    "Join Queue",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                  
                        ],
                    ),
                  ),

                                      

                  SizedBox(height: height * 0.02),

                  Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          title: Opacity(opacity: 0.5, child: Text("FEEDBACK")),
                          subtitle: Opacity(
                            opacity: 0.7,
                            child: Text(
                              "Share your experience at ${widget.bname}",
                            ),
                          ),
                        ),

                        Divider(thickness: 0.3),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: "Title",
                              hintText: "What's the issue about?",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: height * 0.01),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            maxLength: 300,
                            maxLines: 5,
                            controller: decriptionController,
                            decoration: InputDecoration(
                              labelText: "Description",
                              hintText: "Describe Your experience in details",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                await addBusinessFeedback();
                              },
                              child: Text(
                                "Submit Feedback",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
