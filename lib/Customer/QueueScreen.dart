import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
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

  bool userJoined = false;

  Future getRealtimeQueueUpdates() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final uid = decodedToken["uid"];
      debugPrint("UID => $uid");
      final response = await http.get(
        Uri.parse("$BaseUrl/customer/getTotalQueueCount/${widget.bid}/$uid"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final resbody = jsonDecode(response.body);

        setState(() {
          DateTime parsedDate = DateTime.parse(
            resbody["data"]["expectedStartTime"],
          );

          String formatted = DateFormat(
            "dd MMM yyyy, hh:mm a",
          ).format(parsedDate.toLocal());

          queuePresency = true;
          EWT = formatted;
          Postion = resbody["data"]["CurrentPostion"].toString();
          userJoined = true;
          debugPrint("Formatted Date-String $formatted");
        });
      }

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        debugPrint("Error => $body");
        CherryToast.error(title: Text(body["error"])).show(context);
        setState(() {
          queuePresency = false;
          userJoined = false;
          EWT = "";
          Postion = "";
        });
      }
    } catch (e) {
      print("Error => $e");
      if (mounted) {
        setState(() {
          queuePresency = false;
          userJoined = false;
        });
      }
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
        debugPrint("Are u here!");
        CherryToast.success(
          title: Text("Successfully joined the Queue"),
        ).show(context);
        userJoined = true;
        await getRealtimeQueueUpdates();
        Navigator.pop(context);
      }

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Center(
              child: Text(
                "${jsonDecode(response.body)["error"]}",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
        Navigator.pop(context);
        throw Exception("Error => ${response.body} -- ${response.statusCode}");
      }
    } catch (e) {
      print("Error => $e");
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

  void _joinBusinessRoom() {
    socketIO.onceConnected(() {
      socketIO.emit("JoinBusiness", widget.bid);
    });
  }

  void _joinUserRoom(String uid) async {
    socketIO.onceConnected(() {
      socketIO.emit("JoinUser", uid);
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
      print("Error => $e");
    }
  }

  bool _isExiting = false;

  Future exitQueue() async {
    if (_isExiting) return;
    setState(() => _isExiting = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final decodedToken = JwtDecoder.decode(token!);
      final uid = decodedToken["uid"];
      final response = await http.delete(
        Uri.parse("$BaseUrl/customer/exitQueue/${widget.bid}/$uid"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        CherryToast.success(title: Text("Left from Queue")).show(context);
        if (mounted) {
          setState(() {
            userJoined = false;
            queuePresency = false;
            EWT = "";
            Postion = "";
          });
        }
      } else {
        CherryToast.error(title: Text("Something went wrong")).show(context);
        throw Exception("Error => ${response.body} -- ${response.statusCode}");
      }
    } catch (e) {
      print("Error =>$e");
    } finally {
      if (mounted) {
        setState(() => _isExiting = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    TimeDetails = getTimeData();
    socketIO.init(serverUrl: BaseUrl);
    _joinBusinessRoom();

    getAllWorkers();
    getRealtimeQueueUpdates();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    final Color primaryGreen = const Color(0xFF159447);
    final Color lightGreen = const Color(0xFFEAF7EF);
    final Color darkText = const Color(0xFF171717);
    final Color secondaryText = const Color(0xFF777777);
    final Color background = const Color(0xFFF9FAF9);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        backgroundColor: background,

        appBar: Customerappbar(),

        drawer: Customerdrawer(),

        body: RefreshIndicator(
          color: primaryGreen,

          onRefresh: () => getTimeData(),

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 35),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.bname,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: 30,

                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(9),
                        ),

                        child: Icon(
                          Icons.location_on_outlined,
                          color: primaryGreen,
                          size: 18,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          widget.baddress,

                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Text(
                    "Business Details",

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

                    child: Padding(
                      padding: const EdgeInsets.all(8),

                      child: Column(
                        children: [
                          FutureBuilder<Map<String, dynamic>>(
                            future: TimeDetails,

                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.all(18),

                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,

                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primaryGreen,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Text(
                                        "Loading business details...",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.all(12),

                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Something's off. Try again later.",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: secondaryText,
                                          ),
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: _isRefreshing ? null : _refresh,

                                        child: AnimatedRotation(
                                          turns: _isRefreshing ? 1.0 : 0.0,

                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),

                                          child: Icon(
                                            Icons.refresh_rounded,
                                            color: primaryGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    _buildDetailTile(
                                      icon: Icons.access_time_rounded,

                                      title: "Opening Time",

                                      value: snapshot.data!["BST"].toString(),

                                      primaryGreen: primaryGreen,

                                      secondaryText: secondaryText,

                                      darkText: darkText,
                                    ),

                                    Divider(
                                      height: 1,
                                      color: Colors.grey.shade200,
                                    ),

                                    _buildDetailTile(
                                      icon: Icons.access_time_filled_rounded,

                                      title: "Closing Time",

                                      value: snapshot.data!["BET"].toString(),

                                      primaryGreen: primaryGreen,

                                      secondaryText: secondaryText,

                                      darkText: darkText,
                                    ),

                                    Divider(
                                      height: 1,
                                      color: Colors.grey.shade200,
                                    ),

                                    _buildDetailTile(
                                      icon: Icons.people_outline_rounded,

                                      title: "Daily Customer Limit",

                                      value: snapshot
                                          .data!["CustomerLimitPerDay"]
                                          .toString(),

                                      primaryGreen: primaryGreen,

                                      secondaryText: secondaryText,

                                      darkText: darkText,
                                    ),
                                  ],
                                );
                              }

                              return const SizedBox();
                            },
                          ),

                          Divider(height: 1, color: Colors.grey.shade200),

                          _buildDetailTile(
                            icon: Icons.language_rounded,

                            title: "Website",

                            value: "Not available",

                            primaryGreen: primaryGreen,

                            secondaryText: secondaryText,

                            darkText: darkText,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        "Queue",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),

                      GestureDetector(
                        onTap: () async {
                          CherryToast.info(
                            title: const Text("Refreshing Queue"),
                          ).show(context);

                          setState(() {
                            getRealtimeQueueUpdates();
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),

                          decoration: BoxDecoration(
                            color: lightGreen,
                            borderRadius: BorderRadius.circular(9),
                          ),

                          child: Row(
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 16,
                                color: primaryGreen,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                "Refresh",

                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: Colors.grey.shade200),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(14),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              Container(
                                height: 34,
                                width: 34,

                                decoration: BoxDecoration(
                                  color: lightGreen,
                                  borderRadius: BorderRadius.circular(9),
                                ),

                                child: Icon(
                                  Icons.groups_outlined,
                                  size: 19,
                                  color: primaryGreen,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Text(
                                "Worker & Queue Status",

                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: darkText,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          if (allworkers.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 22),

                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 25,
                                      width: 25,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.3,
                                        color: primaryGreen,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "Loading queue status...",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              itemCount: allworkers.length,

                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

                              itemBuilder: (context, index) {
                                final workers = allworkers[index];

                                final bool isActive =
                                    workers["status"] == "active";

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == allworkers.length - 1
                                        ? 0
                                        : 10,
                                  ),

                                  child: Container(
                                    padding: const EdgeInsets.all(12),

                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? lightGreen
                                          : Colors.red.shade50,

                                      borderRadius: BorderRadius.circular(12),

                                      border: Border.all(
                                        color: isActive
                                            ? primaryGreen.withOpacity(0.12)
                                            : Colors.red.withOpacity(0.12),
                                      ),
                                    ),

                                    child: Row(
                                      children: [
                                        Container(
                                          height: 43,
                                          width: 43,

                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Colors.white
                                                : Colors.red.shade100,

                                            shape: BoxShape.circle,
                                          ),

                                          child: Icon(
                                            Icons.person_outline_rounded,
                                            color: isActive
                                                ? primaryGreen
                                                : Colors.red.shade400,
                                            size: 22,
                                          ),
                                        ),

                                        const SizedBox(width: 11),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              Text(
                                                workers["workerName"],

                                                maxLines: 1,

                                                overflow: TextOverflow.ellipsis,

                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: darkText,
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              Text(
                                                "${workers["queueCount"]} customers in queue",

                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: secondaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 5,
                                          ),

                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Colors.white
                                                : Colors.red.shade100,

                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,

                                            children: [
                                              Container(
                                                height: 6,
                                                width: 6,

                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? primaryGreen
                                                      : Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),

                                              const SizedBox(width: 5),

                                              Text(
                                                workers["status"],

                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: isActive
                                                      ? primaryGreen
                                                      : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (queuePresency)
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        color: lightGreen,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(
                          color: primaryGreen.withOpacity(0.15),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              Container(
                                height: 38,
                                width: 38,

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: Icon(
                                  Icons.confirmation_number_outlined,
                                  color: primaryGreen,
                                  size: 21,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      "You're in the queue",

                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: darkText,
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    Text(
                                      "Your position is being updated",

                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Icon(
                                Icons.check_circle_rounded,
                                color: primaryGreen,
                                size: 22,
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: _buildQueueInfoCard(
                                  icon: Icons.format_list_numbered_rounded,

                                  label: "Position",

                                  value: Postion,

                                  primaryGreen: primaryGreen,

                                  darkText: darkText,

                                  secondaryText: secondaryText,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _buildQueueInfoCard(
                                  icon: Icons.schedule_rounded,

                                  label: "Expected Time",

                                  value: EWT,

                                  primaryGreen: primaryGreen,

                                  darkText: darkText,

                                  secondaryText: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 14),

                  if (userJoined)
                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: ElevatedButton.icon(
                        onPressed: _isExiting
                            ? null
                            : () async {
                                await exitQueue();
                              },

                        icon: _isExiting
                            ? const SizedBox(
                                height: 18,
                                width: 18,

                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.logout_rounded, size: 18),

                        label: Text(
                          _isExiting ? "Leaving Queue..." : "Leave Queue",

                          style: const TextStyle(
                            fontSize: 14,
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
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await getServices();

                          if (!loadedDetails || serviceDetailsLoading) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Loading service details kindly wait",
                                ),
                              ),
                            );
                          }

                          showDialog(
                            barrierColor: Colors.black26,

                            context: context,

                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                    title: Row(
                                      children: [
                                        Container(
                                          height: 35,
                                          width: 35,

                                          decoration: BoxDecoration(
                                            color: lightGreen,
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),

                                          child: Icon(
                                            Icons.design_services_outlined,
                                            size: 19,
                                            color: primaryGreen,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        const Text("Select a Service"),
                                      ],
                                    ),

                                    content: SizedBox(
                                      height: height * 0.5,

                                      width: width * 0.8,

                                      child: allServiceDetails.isEmpty
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                color: primaryGreen,
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount:
                                                  allServiceDetails.length,

                                              itemBuilder: (context, index) {
                                                final data =
                                                    allServiceDetails[index];

                                                final isSelected = selectedIndex
                                                    .contains(index);

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 9,
                                                      ),

                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? lightGreen
                                                          : Colors.white,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),

                                                      border: Border.all(
                                                        color: isSelected
                                                            ? primaryGreen
                                                                  .withOpacity(
                                                                    0.35,
                                                                  )
                                                            : Colors
                                                                  .grey
                                                                  .shade200,
                                                      ),
                                                    ),

                                                    child: ListTile(
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 3,
                                                          ),

                                                      title: Text(
                                                        data["name"],

                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: darkText,
                                                        ),
                                                      ),

                                                      subtitle: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),

                                                        child: Text(
                                                          "${data["AvgDurationPerCustomer"]} min · ₹${data["ChargesPerService"]}",

                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                secondaryText,
                                                          ),
                                                        ),
                                                      ),

                                                      trailing: SizedBox(
                                                        height: 34,

                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              if (isSelected) {
                                                                selectedIndex
                                                                    .remove(
                                                                      index,
                                                                    );

                                                                setState(() {
                                                                  serviceIds.remove(
                                                                    data["_id"],
                                                                  );
                                                                });
                                                              } else {
                                                                selectedIndex
                                                                    .add(index);

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
                                                            });
                                                          },

                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                isSelected
                                                                ? primaryGreen
                                                                : Colors.white,

                                                            foregroundColor:
                                                                isSelected
                                                                ? Colors.white
                                                                : primaryGreen,

                                                            elevation: 0,

                                                            side: BorderSide(
                                                              color: primaryGreen
                                                                  .withOpacity(
                                                                    0.4,
                                                                  ),
                                                            ),

                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    9,
                                                                  ),
                                                            ),
                                                          ),

                                                          child: Text(
                                                            isSelected
                                                                ? "Selected"
                                                                : "Select",

                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),

                                    actions: [
                                      serviceIds.isNotEmpty
                                          ? TextButton(
                                              onPressed: () async {
                                                if (serviceIds.length > 2) {
                                                  Navigator.pop(context);

                                                  final messenger =
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      );

                                                  messenger.showMaterialBanner(
                                                    MaterialBanner(
                                                      backgroundColor:
                                                          Colors.red,

                                                      content: const Text(
                                                        "Only 2 services can be selected at a time",

                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),

                                                      actions: [
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.black,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                          ),

                                                          onPressed: () {
                                                            messenger
                                                                .hideCurrentMaterialBanner();
                                                          },

                                                          child: const Text(
                                                            "Close",

                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  Future.delayed(
                                                    const Duration(seconds: 5),
                                                    () {
                                                      if (messenger.mounted) {
                                                        messenger
                                                            .hideCurrentMaterialBanner();
                                                      }
                                                    },
                                                  );
                                                } else {
                                                  await joinQueue();
                                                }
                                              },

                                              child: Text(
                                                "Join Queue",

                                                style: TextStyle(
                                                  color: primaryGreen,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              "Select service",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: secondaryText,
                                              ),
                                            ),

                                      TextButton(
                                        onPressed: () => Navigator.pop(context),

                                        child: Text(
                                          "Cancel",

                                          style: TextStyle(
                                            color: secondaryText,
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

                        icon: const Icon(Icons.add_rounded, size: 20),

                        label: const Text(
                          "Join Queue",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,

                          foregroundColor: Colors.white,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  Text(
                    "Feedback",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Share your experience at ${widget.bname}",

                    style: TextStyle(fontSize: 13, color: secondaryText),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: Colors.grey.shade200),
                    ),

                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,

                          decoration: InputDecoration(
                            labelText: "Title",
                            hintText: "What's the issue about?",

                            labelStyle: TextStyle(color: secondaryText),

                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),

                            prefixIcon: Icon(
                              Icons.title_outlined,
                              color: primaryGreen,
                              size: 20,
                            ),

                            filled: true,
                            fillColor: background,

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 15,
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: BorderSide(
                                color: primaryGreen,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          maxLength: 300,
                          maxLines: 5,

                          controller: decriptionController,

                          decoration: InputDecoration(
                            labelText: "Description",

                            hintText: "Describe your experience in detail",

                            alignLabelWithHint: true,

                            labelStyle: TextStyle(color: secondaryText),

                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),

                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 85),

                              child: Icon(
                                Icons.notes_outlined,
                                color: primaryGreen,
                                size: 20,
                              ),
                            ),

                            filled: true,
                            fillColor: background,

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 15,
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: BorderSide(
                                color: primaryGreen,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        SizedBox(
                          width: double.infinity,
                          height: 46,

                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await addBusinessFeedback();
                            },

                            icon: const Icon(Icons.send_rounded, size: 17),

                            label: const Text(
                              "Submit Feedback",

                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,

                              foregroundColor: Colors.white,

                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
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

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    required Color primaryGreen,
    required Color secondaryText,
    required Color darkText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),

      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(9),
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

                const SizedBox(height: 3),

                Text(
                  value,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

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

  Widget _buildQueueInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color primaryGreen,
    required Color darkText,
    required Color secondaryText,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: primaryGreen.withOpacity(0.12)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primaryGreen),

              const SizedBox(width: 5),

              Text(
                label,

                style: TextStyle(fontSize: 10.5, color: secondaryText),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            value.isEmpty ? "-" : value,

            maxLines: 2,
            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }
}
