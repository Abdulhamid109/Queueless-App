import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/Widgets/flutter_mapp.dart';
import 'package:queueless/Widgets/locationn_error.dart';
import 'package:queueless/admin/serviceeditspage.dart';
import 'package:queueless/admin/workersEditPage.dart';

import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/RequestLocationPermission.dart';
import 'package:queueless/helper/getAddressFromLatLong.dart';
import 'package:queueless/helper/getLatLlongfromAddress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Businesseditpage extends StatefulWidget {
  final String bid;
  const Businesseditpage({super.key, required this.bid});

  @override
  State<Businesseditpage> createState() => _BusinesseditpageState();
}

class _BusinesseditpageState extends State<Businesseditpage> {
  static const Color navy = Color(0xFF1A1A2E);
  static const Color cream = Color(0xFFF5F0EB);
  // var box = Hive.box<Businessinformationmodal>("BusinessBox");
  late Future businessFuture;
  late Future timeFuture;
  double latitude = 0;
  double longitude = 0;
  String currentAddress = "";
  String UpdatedAddress = "";
  bool isloading = false;
  bool step1Completed = false;
  Map<String, double> data = {};
  String businessAddress = "";

  TextEditingController searchAddressController = TextEditingController();
  TextEditingController editBusinessName = TextEditingController();
  TextEditingController editCountryName = TextEditingController();
  TextEditingController editStateName = TextEditingController();
  TextEditingController editPinCodeName = TextEditingController();
  TextEditingController editWebsiteName = TextEditingController();

  // TextEditingController editBST = TextEditingController();
  // TextEditingController editBET = TextEditingController();
  TextEditingController editCLimit = TextEditingController();
  TextEditingController editAdditionalInfo = TextEditingController();

  String updatedBSTTime = "";
  String updatedBETTime = "";
  String previousBSTTime = "";
  String previousBETTime = "";
  String Tid = "";
  // bool updatetimeloader = false;

  String BusinessCategory = "";

  Future<void> getCurrentLocation() async {
    final PermissionGranted = await requestLocationPermission();
    if (!PermissionGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LocationnError(screen: Businesseditpage(bid: widget.bid)),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
    double lat = position.latitude;
    double long = position.longitude;
    // double accuracy = position.accuracy;
    // double speed = position.speed;
    // double heading = position.heading;

    print('--------------Lat: $lat, Long: $long -------------------------');
    final address = await getAddressFromLatLong(
      position.latitude,
      position.longitude,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      currentAddress = address;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    businessFuture = getBusinessDetailsData();
    timeFuture = getTimeDetailsData();
  }

  Future getBusinessDetailsData() async {
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/getBusiness/${widget.bid}"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return jsonBody["data"];
      } else {
        print("Logs => ${response.body} -- ${response.statusCode}");
      }
      return null;
    } catch (e) {
      print("Something went wrong!");
    }
  }

  Future getTimeDetailsData() async {
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/getTimeData/${widget.bid}"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return jsonBody["data"];
      }
    } catch (e) {
      print("Something went wrong => $e");
    }
  }

  Future updateBusinessData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final decodedData = JwtDecoder.decode(token!);
    final adminid = decodedData["uid"];
    try {
      final response = await http.put(
        Uri.parse("$BaseUrl/admin/updateBusinessData/$adminid/${widget.bid}"),
      );
    } catch (e) {
      print("Error => $e");
    }
  }

  Future updateTimeDetails(String tid) async {
    try {
      print("Tid => $tid");
      // if (editCLimit.text.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       duration: Duration(seconds: 1),
      //       content: Center(
      //         child: Text(
      //           "Empty values are forbidden",
      //           style: TextStyle(color: Colors.white),
      //         ),
      //       ),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }
      final response = await http.put(
        Uri.parse("$BaseUrl/admin/updateTimeData/$tid"),
        headers: {'Content-Type': 'application/json'},
        //BST,BET,CustomerLimitPerDay,AdditionalInformation
        body: jsonEncode({
          "BST": updatedBSTTime.isEmpty ? previousBSTTime : updatedBSTTime,
          "BET": updatedBETTime.isEmpty ? previousBETTime : updatedBETTime,
          "CustomerLimitPerDay": editCLimit.text,
          "AdditionalInformation": editAdditionalInfo.text,
        }),
      );

        print("🟡 Step 2 : ${response.statusCode}: ${response.body}");
        // Navigator.pop(context);
      if(response.statusCode==200){
        print("🟡Debug issue why not hereeeeeeeeee");
      }

      if (response.statusCode != 200) {
    throw Exception("${response.statusCode}: ${response.body}"); 
  }
    } catch (e) {
      print("Error => $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    double width = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Update/Make changes in your Data",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: height * 0.01),
              Divider(thickness: 0.3),
              SizedBox(height: height * 0.04),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: ListTile(
                  title: Text("Business Data", style: TextStyle(fontSize: 16)),
                  trailing: IconButton(
                    onPressed: () {
                      showDialog(
                        fullscreenDialog: true,
                        barrierDismissible: false,
                        barrierColor: Colors.black26,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white,
                            title: Center(child: Text("Edit Business Data")),
                            content: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: FutureBuilder(
                                future: businessFuture,
                                builder: (context, asyncSnapshot) {
                                  if (asyncSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (asyncSnapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        "Something went wrong!",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    );
                                  } else if (asyncSnapshot.hasData) {
                                    editBusinessName.text = asyncSnapshot
                                        .data!["BusinessName"]
                                        .toString();
                                    editCountryName.text = asyncSnapshot
                                        .data!["Country"]
                                        .toString();
                                    editStateName.text = asyncSnapshot
                                        .data!["State"]
                                        .toString();
                                    editPinCodeName.text = asyncSnapshot
                                        .data!["pinCode"]
                                        .toString();
                                    editWebsiteName.text = asyncSnapshot
                                        .data!["Website"]
                                        .toString();

                                    businessAddress = asyncSnapshot
                                        .data!["BusinessAddress"]
                                        .toString();

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextField(
                                          controller: editBusinessName,
                                          decoration: InputDecoration(
                                            labelText: "Business Name",
                                            enabledBorder: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.01),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                businessAddress.isEmpty
                                                    ? currentAddress.isEmpty
                                                          ? Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            )
                                                          : Expanded(
                                                              child: Text(
                                                                currentAddress,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                            )
                                                    : Expanded(
                                                        child: Text(
                                                          asyncSnapshot
                                                              .data!["BusinessAddress"]
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: navy,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            7,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      barrierColor:
                                                          const Color.fromARGB(
                                                            190,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                      context: context,
                                                      builder: (context) {
                                                        return StatefulBuilder(
                                                          builder: (context, setState) {
                                                            return AlertDialog(
                                                              title: Center(
                                                                child: Text(
                                                                  "Select Your Address from the map",
                                                                  style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),

                                                              content: SizedBox(
                                                                width:
                                                                    width * 0.8,

                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: TextFormField(
                                                                            keyboardType:
                                                                                TextInputType.text,
                                                                            controller:
                                                                                searchAddressController,
                                                                            decoration: InputDecoration(
                                                                              labelText: "Search",
                                                                              enabledBorder: OutlineInputBorder(),
                                                                              focusedBorder: OutlineInputBorder(),
                                                                            ),
                                                                          ),
                                                                        ),

                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),

                                                                        ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                navy,

                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(
                                                                                7,
                                                                              ),
                                                                            ),
                                                                          ),

                                                                          onPressed: () async {
                                                                            data = await getLatLongfromAddress(
                                                                              searchAddressController.text.toString(),
                                                                            );
                                                                            setState(() {
                                                                              latitude =
                                                                                  data["lat"]
                                                                                      as double;
                                                                              longitude =
                                                                                  data["long"]
                                                                                      as double;
                                                                            });
                                                                          },

                                                                          child: Text(
                                                                            "Search",
                                                                            style: TextStyle(
                                                                              color: cream,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    //here we wiill display our map
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Expanded(
                                                                      child: FlutterMapp(
                                                                        latitude:
                                                                            latitude,
                                                                        longitude:
                                                                            longitude,
                                                                        onAddressChange:
                                                                            (
                                                                              value,
                                                                              lat,
                                                                              long,
                                                                            ) {
                                                                              setState(
                                                                                () {
                                                                                  UpdatedAddress = value;
                                                                                  latitude = lat;
                                                                                  longitude = long;
                                                                                },
                                                                              );
                                                                            },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        .spaceBetween,
                                                                    children: [
                                                                      UpdatedAddress
                                                                              .isEmpty
                                                                          ? Text(
                                                                              "",
                                                                            )
                                                                          : TextButton(
                                                                              onPressed: () {
                                                                                this.setState(
                                                                                  () {
                                                                                    currentAddress = UpdatedAddress;
                                                                                    latitude = latitude;
                                                                                    businessAddress = UpdatedAddress;
                                                                                    // asyncSnapshot.data!["BusinessAddress"].toString() =
                                                                                  },
                                                                                );
                                                                                Navigator.pop(
                                                                                  context,
                                                                                );
                                                                              },
                                                                              child: Text(
                                                                                "Save Address",
                                                                              ),
                                                                            ),
                                                                      TextButton(
                                                                        onPressed: () =>
                                                                            Navigator.pop(
                                                                              context,
                                                                            ),
                                                                        child: Text(
                                                                          "Close Map",
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },

                                                  child: Text(
                                                    "Open Map",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.01),
                                        DropdownMenu(
                                          initialSelection: asyncSnapshot
                                              .data!["BusinessCategory"]
                                              .toString(),
                                          menuStyle: MenuStyle(),
                                          width: width - 30,
                                          hintText: "Select Your Business Type",
                                          dropdownMenuEntries: [
                                            DropdownMenuEntry(
                                              value: "HairSaloon",
                                              label: "HairSaloon",
                                            ),
                                            DropdownMenuEntry(
                                              value: "Clinics",
                                              label: "Clinics",
                                            ),
                                          ],
                                          onSelected: (value) {
                                            print("Value Selected => $value");
                                            setState(() {
                                              BusinessCategory = value!;
                                            });
                                          },
                                        ),
                                        SizedBox(height: height * 0.01),
                                        TextField(
                                          controller: editCountryName,
                                          decoration: InputDecoration(
                                            labelText: "Country",
                                            enabledBorder: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.01),
                                        TextField(
                                          controller: editStateName,
                                          decoration: InputDecoration(
                                            labelText: "State",
                                            enabledBorder: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.01),
                                        TextField(
                                          controller: editPinCodeName,
                                          decoration: InputDecoration(
                                            labelText: "Pin-Code",
                                            enabledBorder: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.01),
                                        TextField(
                                          controller: editWebsiteName,
                                          decoration: InputDecoration(
                                            labelText: "Website",
                                            enabledBorder: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(),
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
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Close"),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text("Update"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.edit_square, color: Colors.blue),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: ListTile(
                  title: Text("Service Data", style: TextStyle(fontSize: 16)),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ServiceEditsPage(bid: widget.bid),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.edit_calendar_outlined,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: ListTile(
                  title: Text("Time Data", style: TextStyle(fontSize: 16)),
                  trailing: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogcontext) {
                          return StatefulBuilder(
                            builder: (sbcontext, dialogSetState) {
                              return AlertDialog(
                                title: Center(child: Text("Edit Time Data")),
                                content: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: FutureBuilder(
                                    future: timeFuture,
                                    builder: (sbcontext, asyncSnapshot) {
                                      if (asyncSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (asyncSnapshot.hasError) {
                                        return Text(
                                          "something went wrong",
                                          style: TextStyle(color: Colors.red),
                                        );
                                      } else if (asyncSnapshot.hasData) {
                                        // editBST.text = asyncSnapshot.data!["BST"]
                                        //     .toString();
                                        // editBET.text = asyncSnapshot.data!["BET"]
                                        //     .toString();
                                        previousBSTTime = asyncSnapshot
                                            .data!["BST"]
                                            .toString();
                                        previousBETTime = asyncSnapshot
                                            .data!["BET"]
                                            .toString();
                                        editCLimit.text = asyncSnapshot
                                            .data!["CustomerLimitPerDay"]
                                            .toString();
                                        editAdditionalInfo.text =
                                            asyncSnapshot
                                                .data!["AdditionalInformation"]
                                                .toString()
                                                .isEmpty
                                            ? ""
                                            : asyncSnapshot
                                                  .data!["AdditionalInformation"]
                                                  .toString();
                                        Tid = asyncSnapshot.data!["_id"]
                                            .toString();
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Business start time",
                                              style: TextStyle(fontSize: 13),
                                              textAlign: TextAlign.start,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  5.0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      updatedBSTTime.isEmpty
                                                          ? asyncSnapshot
                                                                .data!["BST"]
                                                                .toString()
                                                          : updatedBSTTime,
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        final TimeOfDay?
                                                        picked =
                                                            await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay.now(),
                                                            );
                                                        if (picked != null) {
                                                          dialogSetState(() {
                                                            updatedBSTTime =
                                                                picked.format(
                                                                  context,
                                                                );
                                                          });
                                                        }
                                                      },

                                                      child: Text(
                                                        "Edit",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: height * 0.01),
                                            Text(
                                              "Business end time",
                                              style: TextStyle(fontSize: 13),
                                              textAlign: TextAlign.start,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  5.0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      updatedBETTime.isEmpty
                                                          ? asyncSnapshot
                                                                .data!["BET"]
                                                                .toString()
                                                          : updatedBETTime,
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        final TimeOfDay?
                                                        picked =
                                                            await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay.now(),
                                                            );
                                                        if (picked != null) {
                                                          dialogSetState(() {
                                                            updatedBETTime =
                                                                picked.format(
                                                                  context,
                                                                );
                                                          });
                                                        }
                                                      },

                                                      child: Text(
                                                        "Edit",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: height * 0.01),
                                            TextField(
                                              controller: editCLimit,
                                              decoration: InputDecoration(
                                                labelText: "Customer Limit",
                                                enabledBorder:
                                                    OutlineInputBorder(),
                                                focusedBorder:
                                                    OutlineInputBorder(),
                                              ),
                                            ),
                                            SizedBox(height: height * 0.01),
                                            TextField(
                                              controller: editAdditionalInfo,
                                              decoration: InputDecoration(
                                                labelText:
                                                    "Additional Information",
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
                                          onPressed: () async {
                                            await updateTimeDetails(Tid);
                                            if (dialogcontext.mounted) {
                                              Navigator.of(dialogcontext).pop();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Successfully updated!",
                                                  ),
                                                ),
                                              );
                                            }
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
                        },
                      );
                    },
                    icon: Icon(Icons.edit_document, color: Colors.blue),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: ListTile(
                  title: Text("Worker Data", style: TextStyle(fontSize: 16)),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WorkersEditPage(bid: widget.bid),
                        ),
                      );
                    },

                    icon: Icon(Icons.edit_note, color: Colors.blue),
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
