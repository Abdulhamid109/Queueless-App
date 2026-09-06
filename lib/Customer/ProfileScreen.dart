import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:queueless/Customer/FeedbackScreen.dart';
import 'package:queueless/Customer/LoginScreen.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/Widgets/flutter_mapp.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/getLatLlongfromAddress.dart';
import 'package:queueless/helper/handleLogoutFunctionality.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  bool isloading = false;
  Future<Map<String, dynamic>>? _profileDataFuture;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  // TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController searchAddressController = TextEditingController();

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
  // Add these alongside your other controllers/state
  String _originalName = "";
  String _originalPhone = "";
  String _originalAddress = "";
  bool isProfileUpdateloader = false;

  bool get _hasUnsavedChanges =>
      nameController.text != _originalName ||
      phoneController.text != _originalPhone ||
      currentAddress != _originalAddress && currentAddress.isNotEmpty;

  Future<Map<String, dynamic>> getProfile() async {
    setState(() {
      isloading = true;
    });
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final decodedData = JwtDecoder.decode(token!);
      final id = decodedData["uid"];
      final response = await http.get(
        Uri.parse("$BaseUrl/customer/profile/$id"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responsebody = jsonDecode(response.body);
        print("Body => $responsebody");
        List LocationData =
            responsebody["Data"]["CustomerCurrentLocation"]["coordinates"];
        debugPrint("${LocationData[1]} lati");
        setState(() {
          longitude = LocationData[0];
          latitude = LocationData[1];
        });
        return responsebody;
      }
      throw Exception("Failed to fetch profile data");
    } catch (e) {
      print("Error $e");
      throw Exception("Error => $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> _handleNotificationTap(BuildContext context) async {
    try {
      final status = await Permission.notification.status;

      if (status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Notifications are already enabled")),
          );
        }
        return;
      }

      if (status.isDenied) {
        final result = await Permission.notification.request();
        debugPrint("Request result: $result");

        if (result.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Notifications enabled")));
          }
          return;
        }

        if (result.isDenied && context.mounted) {
          _showEnableNotificationDialog(context);
        }
        if (result.isPermanentlyDenied && context.mounted) {
          _showEnableNotificationDialog(context);
        }
        return;
      }

      if (status.isPermanentlyDenied && context.mounted) {
        _showEnableNotificationDialog(context);
      }
    } catch (e) {
      debugPrint("Notification permission error: $e");
    }
  }

  void _showEnableNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enable Notifications"),
        content: Text(
          "Turn on notifications to get updates when your turn is coming up in the queue.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Not Now"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
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
        color: Colors.black,
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

  Future<void> _handleUpdateProfile(BuildContext dialogContext) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    final decodedData = JwtDecoder.decode(token!);
    final id = decodedData["uid"];

    debugPrint("Name => ${nameController.text}");

    final response = await http.put(
      Uri.parse("$BaseUrl/customer/updateProfile/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "updatedName": nameController.text,
        "updatedPhone": phoneController.text,
        "updatedAddress": currentAddress.isEmpty ? _originalAddress : currentAddress,
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    if (response.statusCode == 200) {
      // 1. Refetch — this is what actually rebuilds the profile screen with fresh data
      setState(() {
        _profileDataFuture = getProfile();
      });

      // 2. Reset "unsaved changes" tracking so the button greys out again next time
      _originalName = nameController.text;
      _originalPhone = phoneController.text;
      _originalAddress = currentAddress.isEmpty ? _originalAddress : currentAddress;

      // 3. Close the dialog
      if (dialogContext.mounted) Navigator.pop(dialogContext);

      CherryToast.success(title: Text("Profile updated successfully")).show(context);
    } else {
      final err = jsonDecode(response.body);
      CherryToast.error(title: Text(err["error"] ?? "Update failed")).show(context);
    }
  } catch (e) {
    debugPrint("Update error => $e");
    CherryToast.error(title: Text("Something went wrong")).show(context);
  }
}

  bool deleteloader = false;

  Future <void> deleteProfile()async{
    setState(() {
      deleteloader=true;
    });
    try{
      SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    final decodedData = JwtDecoder.decode(token!);
    final id = decodedData["uid"];
    debugPrint("User id inside the delete method => $id");
      final response = await http.delete(Uri.parse("$BaseUrl/customer/deleteaccount/$id"));
      if(response.statusCode==200){
        CherryToast.success(title: Text("Account successfully deleted"),).show(context);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen(),), (route) => true);
      }
      if(response.statusCode!=200){
        final resbody = await jsonDecode(response.body);
        CherryToast.error(title: Text("Something went wrong"),).show(context);
        debugPrint("error => $resbody");
      }
    }catch(e){
      debugPrint("Error => $e");
    }finally{
      setState(() {
        deleteloader=false;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _profileDataFuture = getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF159447);
    final Color lightGreen = const Color(0xFFEAF7EF);
    final Color darkText = const Color(0xFF171717);
    final Color secondaryText = const Color(0xFF777777);
    final Color background = const Color(0xFFF9FAF9);

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: background,

      appBar: Customerappbar(),

      drawer: Customerdrawer(),

      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileDataFuture,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),

                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                        width: 30,

                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Loading your profile...",
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(25),

                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      Container(
                        height: 70,
                        width: 70,

                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),

                        child: Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade400,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Unable to load profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Something went wrong while fetching your profile.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              var data = snapshot.data!["Data"];

              final String name = data["name"]?.toString() ?? "";

              final String email = data["email"]?.toString() ?? "";

              final String phone = data["phone"]?.toString() ?? "Not provided";

              final String address =
                  data["CustomerAddress"]?.toString() ?? "Not provided";

              final String role = data["role"]?.toString() ?? "";

              final String avatarInitials = name
                  .split(" ")
                  .where((n) => n.isNotEmpty)
                  .map((n) => n[0])
                  .join("")
                  .toUpperCase();

              return Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 35),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Account",

                      style: TextStyle(fontSize: 13, color: secondaryText),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Your Profile",

                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Row(
                        children: [
                          Container(
                            height: 64,
                            width: 64,

                            decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(18),
                            ),

                            alignment: Alignment.center,

                            child: Text(
                              avatarInitials.isEmpty ? "?" : avatarInitials,

                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: primaryGreen,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  name.isEmpty ? "User" : name,

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: darkText,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  email,

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: secondaryText,
                                  ),
                                ),

                                if (role.isNotEmpty) const SizedBox(height: 8),

                                if (role.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),

                                    decoration: BoxDecoration(
                                      color: lightGreen,
                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        Container(
                                          height: 6,
                                          width: 6,

                                          decoration: BoxDecoration(
                                            color: primaryGreen,
                                            shape: BoxShape.circle,
                                          ),
                                        ),

                                        const SizedBox(width: 5),

                                        Text(
                                          role,

                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    Text(
                      "Personal Information",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Column(
                        children: [
                          _buildProfileInfoTile(
                            icon: Icons.person_outline_rounded,
                            title: "Full Name",
                            value: name.isEmpty ? "Not provided" : name,
                            primaryGreen: primaryGreen,
                            darkText: darkText,
                            secondaryText: secondaryText,
                          ),

                          Divider(height: 1, color: Colors.grey.shade200),

                          _buildProfileInfoTile(
                            icon: Icons.email_outlined,
                            title: "Email",
                            value: email.isEmpty ? "Not provided" : email,
                            primaryGreen: primaryGreen,
                            darkText: darkText,
                            secondaryText: secondaryText,
                          ),

                          Divider(height: 1, color: Colors.grey.shade200),

                          _buildProfileInfoTile(
                            icon: Icons.phone_outlined,
                            title: "Phone Number",
                            value: phone,
                            primaryGreen: primaryGreen,
                            darkText: darkText,
                            secondaryText: secondaryText,
                          ),

                          Divider(height: 1, color: Colors.grey.shade200),

                          _buildProfileInfoTile(
                            icon: Icons.location_on_outlined,
                            title: "Address",
                            value: address,
                            primaryGreen: primaryGreen,
                            darkText: darkText,
                            secondaryText: secondaryText,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    Text(
                      "Settings",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Column(
                        children: [
                          _buildSettingTile(
                            icon: Icons.notifications_none_rounded,

                            title: "Notifications",

                            subtitle: "Manage queue notifications",

                            primaryGreen: primaryGreen,

                            darkText: darkText,

                            secondaryText: secondaryText,

                            onTap: () => _handleNotificationTap(context),
                          ),

                          Divider(
                            height: 1,
                            indent: 65,
                            color: Colors.grey.shade200,
                          ),

                          _buildSettingTile(
                            icon: Icons.chat_bubble_outline_rounded,

                            title: "Send Feedback",

                            subtitle: "Help us improve Queueless",

                            primaryGreen: primaryGreen,

                            darkText: darkText,

                            secondaryText: secondaryText,

                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Feedbackscreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    Text(
                      "Account Actions",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 46,

                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,

                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setStateDialog) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                    title: Text("Edit Your Profile"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FutureBuilder(
                                          future: _profileDataFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                "Something went wrong while editing",
                                              );
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            if (snapshot.hasData) {
                                              if (nameController.text.isEmpty) {
                                                nameController.text = snapshot
                                                    .data!["Data"]["name"]
                                                    .toString();
                                                _originalName =
                                                    nameController.text;
                                              }
                                              if (phoneController
                                                  .text
                                                  .isEmpty) {
                                                phoneController.text = snapshot
                                                    .data!["Data"]["phone"]
                                                    .toString();
                                                _originalPhone =
                                                    phoneController.text;
                                              }
                                               _originalAddress = snapshot.data!["Data"]["CustomerAddress"].toString();
                                              return Column(
                                                children: [
                                                  TextField(
                                                    onChanged: (value) =>
                                                        setStateDialog(() {}),
                                                    controller: nameController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          nameController
                                                              .text
                                                              .isEmpty
                                                          ? nameController
                                                                .text = snapshot
                                                                .data!["Data"]["name"]
                                                                .toString()
                                                          : "Full Name",
                                                      enabledBorder:
                                                          OutlineInputBorder(),
                                                      focusedBorder:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  TextFormField(
                                                    onChanged: (value) =>
                                                        setStateDialog(() {}),
                                                    controller: phoneController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          nameController
                                                              .text
                                                              .isEmpty
                                                          ? nameController
                                                                .text = snapshot
                                                                .data!["Data"]["phone"]
                                                                .toString()
                                                          : "Phone no",
                                                      enabledBorder:
                                                          OutlineInputBorder(),
                                                      focusedBorder:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: double.maxFinite,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Column(
                                                        children: [
                                                          Center(
                                                            child:
                                                                currentAddress
                                                                    .isEmpty
                                                                ? Text(
                                                                    snapshot
                                                                        .data!["Data"]["CustomerAddress"]
                                                                        .toString(),
                                                                  )
                                                                : Text(
                                                                    currentAddress,
                                                                  ),
                                                          ),

                                                          SizedBox(height: 10),
                                                          Divider(),
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .lightBlueAccent,
                                                            ),
                                                            onPressed: () {
                                                              showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                barrierColor:
                                                                    const Color.fromARGB(
                                                                      190,
                                                                      0,
                                                                      0,
                                                                      0,
                                                                    ),

                                                                context:
                                                                    context,
                                                                builder: (context) {
                                                                  return StatefulBuilder(
                                                                    builder:
                                                                        (
                                                                          context,
                                                                          setState,
                                                                        ) {
                                                                          return AlertDialog(
                                                                            title: Center(
                                                                              child: Text(
                                                                                "Select Your Address from the map",
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),

                                                                            content: SizedBox(
                                                                              width:
                                                                                  width *
                                                                                  0.8,

                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: TextFormField(
                                                                                          keyboardType: TextInputType.text,
                                                                                          controller: searchAddressController,
                                                                                          decoration: _fieldDecoration(
                                                                                            "location",
                                                                                            Icons.search,
                                                                                          ),
                                                                                        ),
                                                                                      ),

                                                                                      SizedBox(
                                                                                        width: 10,
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

                                                                                        onPressed: () async {
                                                                                          data = await getLatLongfromAddress(
                                                                                            searchAddressController.text.toString(),
                                                                                          );
                                                                                          setState(
                                                                                            () {
                                                                                              latitude =
                                                                                                  data["lat"]
                                                                                                      as double;
                                                                                              longitude =
                                                                                                  data["long"]
                                                                                                      as double;
                                                                                            },
                                                                                          );
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
                                                                                    height: 10,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: FlutterMapp(
                                                                                      latitude: latitude,
                                                                                      longitude: longitude,
                                                                                      onAddressChange:
                                                                                          (
                                                                                            value,
                                                                                            lat,
                                                                                            long,
                                                                                          ) {
                                                                                            setState(
                                                                                              () {
                                                                                                print(
                                                                                                  "The Address comming from the Child widget---- $value",
                                                                                                );
                                                                                                UpdatedAddress = value;
                                                                                                latitude = lat;
                                                                                                longitude = long;

                                                                                                print(
                                                                                                  "The Address comming from the Child widget---- $UpdatedAddress",
                                                                                                );
                                                                                              },
                                                                                            );
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
                                                                                  UpdatedAddress.isEmpty
                                                                                      ? Text(
                                                                                          "",
                                                                                        )
                                                                                      : TextButton(
                                                                                          onPressed: () {
                                                                                            this.setState(
                                                                                              () {
                                                                                                currentAddress = UpdatedAddress;
                                                                                                latitude = latitude;
                                                                                                longitude = longitude;
                                                                                              },
                                                                                            );
                                                                                            setStateDialog(
                                                                                              () {},
                                                                                            );

                                                                                            Navigator.pop(
                                                                                              context,
                                                                                            );
                                                                                            debugPrint(
                                                                                              "Data => ${currentAddress} - la -$latitude - lo-$longitude",
                                                                                            );
                                                                                          },
                                                                                          child: Text(
                                                                                            "Save Address",
                                                                                          ),
                                                                                        ),
                                                                                  TextButton(
                                                                                    onPressed: () => Navigator.pop(
                                                                                      context,
                                                                                    ),
                                                                                    child: Text(
                                                                                      "Close Map",
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Text(
                                                              "Change Address",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: double.maxFinite,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade400,
                                                      border: Border.all(),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        CherryToast.error(
                                                          title: Text(
                                                            "Email can't be changed!",
                                                          ),
                                                        ).show(context);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Center(
                                                          child: Text(
                                                            snapshot
                                                                .data!["Data"]["email"]
                                                                .toString(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return Text("");
                                          },
                                        ),
                                      ],
                                    ),

                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                            onPressed: _hasUnsavedChanges
                                                ? () async{
                                                    await _handleUpdateProfile(context);
                                                  }
                                                : null,
                                            child: Text(
                                              "Update",
                                              style: TextStyle(
                                                color: _hasUnsavedChanges
                                                    ? primaryGreen
                                                    : Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),

                                            child: Text(
                                              "Close",
                                              style: TextStyle(
                                                color: primaryGreen,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },

                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: primaryGreen,
                        ),

                        label: Text(
                          "Edit Profile",

                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: primaryGreen,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: primaryGreen.withOpacity(0.35),
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 46,

                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                          barrierDismissible: false,
                          barrierColor: Colors.black38,
                          context: context, builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            title: Center(child: Text("Are You sure you want to Logout?",style: TextStyle(fontSize: 17),textAlign: TextAlign.center,)),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  TextButton(onPressed: ()async{
                                    await onhandleLogout(context, LoginScreen());
                                  }, child: Text("Logout")),
                                  TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel"))
                                ],
                              )
                            ],
                          );
                        },);
                        },

                        icon: const Icon(Icons.logout_rounded, size: 18),

                        label: const Text(
                          "Logout",

                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,

                          foregroundColor: Colors.white,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 46,

                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                          barrierDismissible: false,
                          barrierColor: Colors.black38,
                          context: context, builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            title: Center(child: Text("Are You sure you want to Delete Account?",style: TextStyle(fontSize: 17),textAlign: TextAlign.center,)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(child: Text("This action is irreversible",style: TextStyle(color: Colors.red,),),),
                              ],
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  TextButton(onPressed: ()async{
                                    // await onhandleLogout(context, LoginScreen());
                                    await deleteProfile();
                                  }, child: deleteloader?Center(child: CircularProgressIndicator(),):Text("Delete")),
                                  TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel"))
                                ],
                              )
                            ],
                          );
                        },);
                        },

                        icon: const Icon(Icons.delete, size: 18),

                        label: const Text(
                          "Delete Account",

                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,

                          foregroundColor: Colors.white,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 15),

                    Center(
                      child: Text(
                        "Queueless",

                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color primaryGreen,
    required Color darkText,
    required Color secondaryText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            height: 38,
            width: 38,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, size: 19, color: primaryGreen),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(fontSize: 11.5, color: secondaryText),
                ),

                const SizedBox(height: 4),

                Text(
                  value,

                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryGreen,
    required Color darkText,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),

          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EF),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(icon, size: 20, color: primaryGreen),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,

                      style: TextStyle(fontSize: 11.5, color: secondaryText),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
