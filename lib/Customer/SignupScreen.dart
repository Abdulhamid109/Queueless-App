import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:queueless/Customer/LoginScreen.dart';
import 'package:queueless/Widgets/flutter_mapp.dart';
import 'package:queueless/Widgets/locationn_error.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/RequestLocationPermission.dart';
import 'package:queueless/helper/getAddressFromLatLong.dart';
import 'package:queueless/helper/getLatLlongfromAddress.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  static const Color navy = Color(0xFF1A1A2E);
  static const Color cream = Color(0xFFF5F0EB);
  static const Color gold = Color(0xFFC9A96E);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E1D8);
  static const Color mutedText = Color(0xFF8A7E72);

  double latitude = 0;
  double longitude = 0;
  String currentAddress = "";
  String UpdatedAddress = "";
  bool isloading = false;

  Future<void> getCurrentLocation() async {
    final PermissionGranted = await requestLocationPermission();
    if (!PermissionGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocationnError(screen: SignupScreen(),)),
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

  Future<void> handleSignup() async{
    setState(() {
      isloading=true;
    });
    try {
      final response = await http.post(
        Uri.parse("$BaseUrl/customer/auth/signup"),
        headers: {'Content-Type':'application/json'},
        body: jsonEncode({
          'FullName':nameController.text.toString(),
          'email':emailController.text.toString().toLowerCase(),
          'password':passwordController.text,
          'phone':phoneController.text,
          'CustomerAddress':UpdatedAddress.isEmpty?currentAddress:UpdatedAddress,
          'latitude':latitude,
          'longitude':longitude,
        })
      );
      if (response.statusCode == 200) {
        var decodedbody = jsonDecode(response.body);
        print("Data Body => ${decodedbody}");
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        phoneController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully Account created...redirecting to LoginPage"),
            duration: Duration(seconds: 1),
          ),
        ).closed.then((value) => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(),)),);
      } else {
        print(
          "Some Error happened with code as ${response.statusCode} => ${response.body} ",
        );
        var error = jsonDecode(response.body);
        final messenger = ScaffoldMessenger.of(context);
        messenger.showMaterialBanner(
          MaterialBanner(
            backgroundColor: Colors.red.shade200,
            leading: Icon(Icons.error, color: Colors.red),
            content: Text(error["error"]),
            actions: [
              TextButton(
                onPressed: () {
                  messenger.hideCurrentMaterialBanner();
                },
                child: Text(
                  "Dismiss",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),
        );
        Future.delayed(Duration(seconds: 5), () {
          if (messenger.mounted) {
            messenger.hideCurrentMaterialBanner();
          }
        });
      }
    } catch (e) {
      print("Something went wrong $e");
    }finally{
      setState(() {
      isloading=false;
    });
    }
  }

  InputDecoration _fieldDecoration(
    String label,
    IconData prefix, {
    IconData? suffix,
    VoidCallback? onSuffixTap,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: mutedText,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        color: gold,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
      prefixIcon: Icon(prefix, color: mutedText, size: 20),
      suffixIcon: suffix != null
          ? GestureDetector(
              onTap: onSuffixTap,
              child: Icon(suffix, color: mutedText, size: 20),
            )
          : null,
      filled: true,
      fillColor: fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getLatLongfromAddress("Ghansoli");
  }

  TextEditingController searchAddressController = TextEditingController();
  Map<String,double> data = {};

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: navy,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "WELCOME ",
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Create your account",
                    style: TextStyle(
                      color: cream,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          decoration: _fieldDecoration(
                            "Full_Name",
                            Icons.person,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Enter your full Name";
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _fieldDecoration(
                            "Email address",
                            Icons.mail_outline_rounded,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Enter your email";
                            if (!v.contains('@')) return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: _fieldDecoration(
                            "Password",
                            Icons.lock_outline_rounded,
                            suffix: _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixTap: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Enter your password";
                            if (v.length < 8)
                              return "Password must be at least 8 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _fieldDecoration("Phone No", Icons.phone),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Enter your Phone no";
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // An Alert Dialog indicating the map (flutter_map)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: fieldBg,
                            border: Border.all(color: gold),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                currentAddress.isEmpty
                                    ? Center(child: CircularProgressIndicator())
                                    : Expanded(child: Text(currentAddress,overflow: TextOverflow.ellipsis,maxLines: 1,)),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: navy,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      barrierDismissible: false,
                                      barrierColor: const Color.fromARGB(190, 0, 0, 0),

                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(builder: (context, setState) {
                                          return AlertDialog(
                                          title: Center(
                                            child: Text(
                                              "Select Your Address from the map",
                                              style: TextStyle(fontSize: 16),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),

                                          content: SizedBox(
                                            width: width * 0.8,

                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType.text,
                                                        controller: searchAddressController,
                                                        decoration:
                                                            _fieldDecoration(
                                                              "location",
                                                              Icons.search,
                                                            ),
                                                      ),
                                                    ),

                                                    SizedBox(width: 10),

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

                                                      onPressed: () async{
                                                        data = await getLatLongfromAddress(searchAddressController.text.toString());
                                                              setState(() {
                                                                latitude = data["lat"] as double;
                                                                longitude = data["long"] as double;
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
                                                SizedBox(height: 10),
                                                Expanded(
                                                  child: FlutterMapp(
                                                    latitude: latitude,
                                                    longitude: longitude,
                                                    onAddressChange: (value,lat,long) {
                                                      setState(() {
                                                        print("The Address comming from the Child widget---- $value");
                                                        UpdatedAddress = value;
                                                        latitude=lat;
                                                        longitude=long;

                                                        print("The Address comming from the Child widget---- $UpdatedAddress");
                                                      });
                                                      
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: .spaceBetween,
                                              children: [
                                                UpdatedAddress.isEmpty?Text(""):TextButton(
                                                  onPressed: (){
                                                    this.setState((){
                                                      currentAddress = UpdatedAddress;
                                                      latitude = latitude;
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Save Address"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text("Close Map"),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      
                                        },);
                                      },
                                    );
                                  },

                                  child: Text(
                                    "Open Map",
                                    style: TextStyle(color: cream),
                                  ),
                                ),
                              ],
                            ),
                          
                          ),
                        ),

                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                handleSignup();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navy,
                              foregroundColor: cream,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: isloading?
                            Center(child: CircularProgressIndicator(),)
                            :const Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 12, color: mutedText),
                              children: [
                                TextSpan(text: "Already have an account? "),
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String letter, String label, {IconData? icon}) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4A4A4A),
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null
              ? Icon(icon, size: 16, color: const Color(0xFF4A4A4A))
              : Text(
                  letter,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
