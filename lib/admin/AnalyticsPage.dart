import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:queueless/admin/CustomerRententionPage.dart';
import 'package:queueless/admin/ExpensePage.dart';
import 'package:queueless/admin/businessFeedback.dart';
import 'package:queueless/constant/env.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Analyticspage extends StatefulWidget {
  final String bussinessId;
  final String businessName;
  final String businessAddress;
  const Analyticspage({
    super.key,
    required this.bussinessId,
    required this.businessAddress,
    required this.businessName,
  });

  @override
  State<Analyticspage> createState() => _AnalyticspageState();
}

class ChartData {
  ChartData(this.x, this.y, this.text, [this.color]);
  final String x;
  final double y;
  final String text;
  final Color? color;
}

class _AnalyticspageState extends State<Analyticspage> {
  Future<Map<String, dynamic>>? _timeDetails;

  Future<Map<String, dynamic>> getTimeDetails() async {
    try {
      final response = await http.get(
        Uri.parse("$BaseUrl/admin/getTimeData/${widget.bussinessId}"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      }
      throw Exception(
        "responseCode :${response.statusCode} ,Body :${response.body}",
      );
    } catch (e) {
      print("Error => $e");
      throw "Error => $e";
    }
  }

  @override
  void initState() {
    super.initState();
    _timeDetails = getTimeDetails();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    // double width = MediaQuery.of(context).size.width * 1;
    final List<ChartData> chartData = [
      ChartData('Positive [Rating > 3]', 75, "+ve",Colors.green),
      ChartData('Negative [Rating < 3]', 25, '-ve',Colors.red),
    ];
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Business Details",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Business Name : ${widget.businessName}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Business Address : ${widget.businessAddress}",
                          ),
                        ),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _timeDetails,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                "Something went wrong => ${snapshot.error}",
                              );
                            } else if (snapshot.hasData) {
                              return SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Business Start Time : ${snapshot.data!["data"]["BST"]}",
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Business End Time : ${snapshot.data!["data"]["BET"]}",
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Customer Per Day : ${snapshot.data!["data"]["CustomerLimitPerDay"]}",
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Text("");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),
              Text(
                "Analytics & Growth",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),

              SizedBox(
                height: height * 0.1,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Expensepage(bid: widget.bussinessId,)),
                  ),
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text("Expense Calculation")),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),

              SizedBox(
                height: height * 0.1,
                child: GestureDetector(
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerRententionGraphpage(),)),
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text("Customer Retention Trend")),
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),
              Text(
                "Ratings",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),

              SizedBox(
                height: height * 0.1,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: Center(
                            child: Text(
                              "Your Business Rating",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          content: SizedBox(
                            height: height * 0.4,
                            // width: width * 0.8,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: SfCircularChart(
                                    legend: Legend(
    isVisible: true,
    position: LegendPosition.top,
    overflowMode: LegendItemOverflowMode.wrap,
  ),
                                    series: <CircularSeries>[
                                      // Render pie chart
                                      PieSeries<ChartData, String>(
                                        dataSource: chartData,
                                        pointColorMapper: (ChartData data, _) =>
                                            data.color,
                                        xValueMapper: (ChartData data, _) =>
                                            data.x,
                                        yValueMapper: (ChartData data, _) =>
                                            data.y,
                                        dataLabelMapper: (ChartData data, _) =>
                                            data.text,
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                              isVisible: true,
                                              labelPosition:
                                                  ChartDataLabelPosition
                                                      .outside,
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
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text("Business Rating Chart")),
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),
              Text(
                "Feedbacks",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),

              SizedBox(
                height: height * 0.1,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BusinessFeedback(bid: widget.bussinessId,)),
                  ),
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text("Customer Feedbacks")),
                    ),
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
