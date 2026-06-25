import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:queueless/Widgets/flutter_mapp.dart';
import 'package:queueless/Widgets/locationn_error.dart';
import 'package:queueless/admin/AdminHomePage.dart';
import 'package:queueless/admin/BusinessOnboarding/WorkerInformation.dart';
import 'package:queueless/helper/RequestLocationPermission.dart';
import 'package:queueless/helper/getAddressFromLatLong.dart';
import 'package:queueless/helper/getLatLlongfromAddress.dart';
import 'package:queueless/models/businessInformationModal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Businessinformation extends StatefulWidget {
  const Businessinformation({super.key});

  @override
  State<Businessinformation> createState() => _BusinessinformationState();
}

class _BusinessinformationState extends State<Businessinformation> {
  static const Color navy = Color(0xFF1A1A2E);
  static const Color cream = Color(0xFFF5F0EB);
  var box = Hive.box<Businessinformationmodal>("BusinessBox");

  double latitude = 0;
  double longitude = 0;
  String currentAddress = "";
  String UpdatedAddress = "";
  bool isloading = false;
  bool step1Completed = false;

  Future<void> getCurrentLocation() async {
    final PermissionGranted = await requestLocationPermission();
    if (!PermissionGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationnError(screen: Businessinformation()),
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

    loadSharedPref();
  }

  Future<void> loadSharedPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      step1Completed = pref.getBool("Step1") ?? false;

      if (!step1Completed) {
        getCurrentLocation();
      }
    });
  }

  TextEditingController BusinessName = TextEditingController();
  TextEditingController searchAddressController = TextEditingController();
  String BusinessCategory = "";
  TextEditingController Country = TextEditingController();
  TextEditingController State = TextEditingController();
  TextEditingController City = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController website = TextEditingController();

  // Fieldds

  Map<String, double> data = {};

  Future<void> onhandleBusinessInformation() async {
    setState(() {
      isloading = true;
    });
    try {
      if (BusinessName.text.isEmpty ||
          currentAddress.isEmpty ||
          BusinessCategory.isEmpty ||
          Country.text.isEmpty ||
          State.text.isEmpty ||
          pinCode.text.isEmpty) {
        return showDialog(
          barrierColor: Colors.black45,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Kindly enter full values"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      } else if (latitude.isNaN || longitude.isNaN) {
        return showDialog(
          barrierColor: Colors.black45,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "something went wrong with location fetching try restarting the app....",
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    ),
                    TextButton(
                      onPressed: () => SystemNavigator.pop(),
                      child: Text("Restart App"),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }
      SharedPreferences pref = await SharedPreferences.getInstance();
      Businessinformationmodal businessinfo = Businessinformationmodal(
        businessName: BusinessName.text.toString(),
        businessAddress: currentAddress,
        businessCategory: BusinessCategory,
        country: Country.text.toString(),
        state: State.text.toString(),
        city: City.text.toString(),
        pinCode: pinCode.text.toString(),
        website: website.text.toString(),
        latitude: latitude,
        longitude: longitude,
      );

      box.put("BusinessInfo", businessinfo);

      pref
          .setBool("Step1", true)
          .then(
            (value) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Workerinformation()),
            ),
          );

      print("Successfully Saved the BusinessInformation");
    } catch (e) {
      print("error $e");
    } finally {
      setState(() {
        isloading = false;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: step1Completed
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Step 1 already completed",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Opacity(
                          opacity: 0.7,
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Workerinformation(),
                              ),
                            ),
                            child: Text(
                              "Click here to navigate to Next Step",
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              pref.remove("Step1");
                              box.clear();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Businessinformation(),
                                ),
                              );
                            },
                            child: Text(
                              "Clear previous Data",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: <Widget>[
                    //  SizedBox(height: height * 0.1),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Step 01 - Business Information",
                          textAlign: .center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: BusinessName,
                              decoration: InputDecoration(
                                labelText: "Business Name",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(15),
                              // clipper: CustomClipper(reclip: Listenable.merge()),
                              child: DropdownMenu(
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
                            ),
                            SizedBox(height: height * 0.01),
                            TextFormField(
                              controller: Country,
                              decoration: InputDecoration(
                                labelText: "Country",
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
                              controller: State,
                              decoration: InputDecoration(
                                labelText: "State",
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
                              controller: City,
                              decoration: InputDecoration(
                                labelText: "City",
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
                              controller: pinCode,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Pin-Code",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    currentAddress.isEmpty
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Expanded(
                                            child: Text(
                                              currentAddress,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: navy,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          barrierDismissible: false,
                                          barrierColor: const Color.fromARGB(
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
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),

                                                  content: SizedBox(
                                                    width: width * 0.8,

                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: TextFormField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .text,
                                                                controller:
                                                                    searchAddressController,
                                                                decoration: InputDecoration(
                                                                  labelText:
                                                                      "Search",
                                                                  enabledBorder:
                                                                      OutlineInputBorder(),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(),
                                                                ),
                                                              ),
                                                            ),

                                                            SizedBox(width: 10),

                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    navy,

                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        7,
                                                                      ),
                                                                ),
                                                              ),

                                                              onPressed: () async {
                                                                data = await getLatLongfromAddress(
                                                                  searchAddressController
                                                                      .text
                                                                      .toString(),
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
                                                                style:
                                                                    TextStyle(
                                                                      color:
                                                                          cream,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        //here we wiill display our map
                                                        SizedBox(height: 10),
                                                        Expanded(
                                                          child: FlutterMapp(
                                                            latitude: latitude,
                                                            longitude:
                                                                longitude,
                                                            onAddressChange:
                                                                (
                                                                  value,
                                                                  lat,
                                                                  long,
                                                                ) {
                                                                  setState(() {
                                                                    print(
                                                                      "The Address comming from the Child widget---- $value",
                                                                    );
                                                                    UpdatedAddress =
                                                                        value;
                                                                    latitude =
                                                                        lat;
                                                                    longitude =
                                                                        long;

                                                                    print(
                                                                      "The Address comming from the Child widget---- $UpdatedAddress",
                                                                    );
                                                                  });
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
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            .spaceBetween,
                                                        children: [
                                                          UpdatedAddress.isEmpty
                                                              ? Text("")
                                                              : TextButton(
                                                                  onPressed: () {
                                                                    this.setState(() {
                                                                      currentAddress =
                                                                          UpdatedAddress;
                                                                      latitude =
                                                                          latitude;
                                                                    });
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
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: height * 0.01),
                            TextFormField(
                              controller: website,
                              decoration: InputDecoration(
                                labelText: "Website (optional)",
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
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(10),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Adminhomepage(),
                                            ),
                                          ),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.01),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        onhandleBusinessInformation();
                                      },
                                      child: Text(
                                        "Next",
                                        style: TextStyle(color: Colors.white),
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
                  ],
                ),
        ),
      ),
    );
  }
}
