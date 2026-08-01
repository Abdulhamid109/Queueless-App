import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queueless/Widgets/AdminAppBar.dart';
import 'package:queueless/Widgets/AdminDrawer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomerRententionGraphpage extends StatefulWidget {
  const CustomerRententionGraphpage({super.key});

  @override
  State<CustomerRententionGraphpage> createState() =>
      _CustomerRententionpageSGraphtate();
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}

class _CustomerRententionpageSGraphtate
    extends State<CustomerRententionGraphpage> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;
  @override
  void initState() {
    data = [
      _ChartData('JAN', 12),
      _ChartData('FEB', 15),
      _ChartData('MAR', 30),
      _ChartData('APR', 6.4),
      _ChartData('MAY', 14),
      _ChartData('JUN', 12),
      _ChartData('JUL', 15),
      _ChartData('AUG', 30),
      _ChartData('SEPT', 6.4),
      _ChartData('OCT', 14),
      _ChartData('NOV', 14),
      _ChartData('DEC', 14),
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      appBar: Adminappbar(),
      drawer: Admindrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              SizedBox(height: height * 0.01),
              Text(
                "Visualization of Monthly Customer Retention",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.03),
      
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 40,
                    interval: 10,
                  ),
                  tooltipBehavior: _tooltip,
                  series: <CartesianSeries<_ChartData, String>>[
                    BarSeries<_ChartData, String>(
                      dataSource: data,
                      xValueMapper: (_ChartData data, _) => data.x,
                      yValueMapper: (_ChartData data, _) => data.y,
                      name: 'Gold',
                      color: Color.fromRGBO(8, 142, 255, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
