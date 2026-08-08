import 'dart:convert';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:queueless/Customer/QueueScreen.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/Widgets/locationn_error.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/RequestLocationPermission.dart';

class Businesscategoryscreen extends StatefulWidget {
  final String bCategory;

  const Businesscategoryscreen({super.key, required this.bCategory});

  @override
  State<Businesscategoryscreen> createState() => _BusinesscategoryscreenState();
}

class _BusinesscategoryscreenState extends State<Businesscategoryscreen> {
  List<dynamic> allbusiness = [];
  bool isloading = false;
  bool hasLoaded = false;

  double latitude = 0;
  double longitude = 0;

  TextEditingController searchController = TextEditingController();

  TextEditingController businessSearchController = TextEditingController();

  List<dynamic> filteredBusiness = [];

  final Color primaryGreen = const Color(0xFF159447);
  final Color lightGreen = const Color(0xFFEAF7EF);
  final Color darkText = const Color(0xFF171717);
  final Color secondaryText = const Color(0xFF777777);

  void filterBusinesses(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredBusiness = allbusiness;
      } else {
        filteredBusiness = allbusiness
            .where(
              (b) => b["BusinessName"].toString().toLowerCase().contains(
                query.trim().toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  Future<void> getCurrentLocation() async {
    final PermissionGranted = await requestLocationPermission();

    if (!PermissionGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationnError(
            screen: Businesscategoryscreen(bCategory: widget.bCategory),
          ),
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

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    await getAllBusinessBasedOnCategory();
  }

  Future getAllBusinessBasedOnCategory() async {
    setState(() {
      isloading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "$BaseUrl/customer/getBusinessBasedOnCat/${widget.bCategory}",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          allbusiness = responseBody["data"];
          filteredBusiness = allbusiness;
        });
      }

      if (response.statusCode != 200) {
        throw Exception("Error => ${response.statusCode} -- ${response.body}");
      }
    } catch (e) {
      print("Error Occured! => $e");
    } finally {
      setState(() {
        isloading = false;
        hasLoaded = true;
      });
    }
  }

  Future getAllBusinessForIncreasedRadius(String radius) async {
    setState(() {
      isloading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$BaseUrl/admin/getBusinessBasedonRad/${widget.bCategory}"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
          "radius": radius,
        }),
      );

      if (response.statusCode == 200) {
        final resbody = await jsonDecode(response.body);

        setState(() {
          allbusiness = resbody["data"];
          filteredBusiness = allbusiness;
        });

        CherryToast.success(
          title: Text(
            "Successfully fetched businesses within the range of ${searchController.text} KM",
          ),
        ).show(context);
      }
    } catch (e) {
      print("Error Occured! => $e");
    } finally {
      setState(() {
        isloading = false;
        hasLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAF9),

        appBar: Customerappbar(),

        drawer: Customerdrawer(),

        body: RefreshIndicator(
          color: primaryGreen,
          onRefresh: () => getCurrentLocation(),

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "${widget.bCategory} Near You",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: primaryGreen,
                          size: 17,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Text(
                        isloading
                            ? "Finding businesses..."
                            : "${filteredBusiness.length} businesses found",
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  TextField(
                    controller: businessSearchController,
                    onChanged: filterBusinesses,

                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,

                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: primaryGreen,
                      ),

                      hintText: "Search business name",

                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),

                      suffixIcon: businessSearchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                              onPressed: () {
                                businessSearchController.clear();

                                filterBusinesses("");
                              },
                            )
                          : null,

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primaryGreen, width: 1.2),
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.025),

                  Divider(thickness: 0.5, color: Colors.grey.shade200),

                  SizedBox(height: height * 0.025),

                  if (!hasLoaded || isloading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 45),

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
                              "Finding businesses near you...",
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filteredBusiness.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 35),

                        child: Column(
                          children: [
                            Container(
                              height: 72,
                              width: 72,
                              decoration: BoxDecoration(
                                color: lightGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.storefront_outlined,
                                size: 34,
                                color: primaryGreen,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Text(
                              "No ${widget.bCategory} found nearby",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: darkText,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Try expanding your search radius.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryText,
                              ),
                            ),

                            const SizedBox(height: 18),

                            TextField(
                              controller: searchController,
                              keyboardType: TextInputType.number,

                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,

                                hintText: "Enter radius (5KM to 10KM)",

                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),

                                prefixIcon: Icon(
                                  Icons.radar_outlined,
                                  color: primaryGreen,
                                  size: 21,
                                ),

                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 15,
                                ),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: primaryGreen,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();

                                  if (searchController.text.isEmpty) {
                                    CherryToast.error(
                                      title: const Text(
                                        "search field cannot be empty",
                                      ),
                                    ).show(context);
                                  }

                                  if (int.tryParse(
                                        searchController.text.toString(),
                                      )! >
                                      10) {
                                    CherryToast.error(
                                      title: const Text(
                                        "Radius range should be within 10KM",
                                      ),
                                    ).show(context);
                                  }

                                  await getAllBusinessForIncreasedRadius(
                                    searchController.text,
                                  );
                                },

                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),

                                label: const Text(
                                  "Fetch Businesses",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),

                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryGreen,

                                  side: BorderSide(
                                    color: primaryGreen.withOpacity(0.35),
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      itemCount: filteredBusiness.length,

                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemBuilder: (context, index) {
                        final data = filteredBusiness[index];

                        final avatarInitials = data["BusinessName"]
                            .toString()
                            .split(" ")
                            .map((n) => n[0])
                            .join("")
                            .toUpperCase();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: Material(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(16),

                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),

                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Queuescreen(
                                    bid: data["_id"],
                                    bname: data["BusinessName"],
                                    baddress: data["BusinessAddress"],
                                  ),
                                ),
                              ),

                              child: Container(
                                padding: const EdgeInsets.all(15),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),

                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,

                                          decoration: BoxDecoration(
                                            color: lightGreen,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),

                                          alignment: Alignment.center,

                                          child: Text(
                                            avatarInitials,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: primaryGreen,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 13),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              Text(
                                                data["BusinessName"],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,

                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: darkText,
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on_outlined,
                                                    size: 14,
                                                    color: secondaryText,
                                                  ),

                                                  const SizedBox(width: 4),

                                                  Expanded(
                                                    child: Text(
                                                      data["BusinessAddress"],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: secondaryText,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    Divider(
                                      height: 1,
                                      color: Colors.grey.shade200,
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,

                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),

                                              child: Icon(
                                                Icons.near_me_outlined,
                                                size: 16,
                                                color: secondaryText,
                                              ),
                                            ),

                                            const SizedBox(width: 7),

                                            Text(
                                              "${double.parse(data["distance"].toString()).toStringAsFixed(2)} m",

                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(
                                          height: 40,

                                          child: ElevatedButton.icon(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Queuescreen(
                                                  bid: data["_id"],
                                                  bname: data["BusinessName"],
                                                  baddress:
                                                      data["BusinessAddress"],
                                                ),
                                              ),
                                            ),

                                            icon: const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16,
                                            ),

                                            label: const Text(
                                              "Open",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryGreen,

                                              foregroundColor: Colors.white,

                                              elevation: 0,

                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),

                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
