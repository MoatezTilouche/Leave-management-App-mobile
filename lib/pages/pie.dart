import 'package:flutter/material.dart';
import 'package:intern_app/pages/pie_chart.dart';
import 'package:intern_app/services/pie_chart_service.dart';

class LeaveTypePieChart extends StatefulWidget {
  @override
  _LeaveTypePieChartState createState() => _LeaveTypePieChartState();
}

class _LeaveTypePieChartState extends State<LeaveTypePieChart> {
  PieChartService apiService = PieChartService();
  List<Map<String, dynamic>> leaveStatistics = [];

  @override
  void initState() {
    super.initState();
    fetchLeaveStatistics();
  }

  Future<void> fetchLeaveStatistics() async {
    try {
      final List<Map<String, dynamic>> data =
          await apiService.fetchLeaveStatistics();
      setState(() {
        leaveStatistics = data;
      });
    } catch (e) {
      print('Error fetching leave statistics: $e');
      // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return leaveStatistics.isEmpty
        ? const Center(child: CircularProgressIndicator.adaptive())
        : Column(
            children: [
              Text(
                'Leave Type Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              Container(child: PieChartSample(data: leaveStatistics)),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  leaveStatistics.length,
                  (index) => LegendItem(
                    color: getColor(index),
                    text: leaveStatistics[index]['type'].toString(),
                  ),
                ),
              ),
            ],
          );
  }

  Color getColor(int index) {
    const colors = [
     Color(0xFFE4003A),
      Color(0xFF80C4E9),
      Color(0xFF32012F),
      Color(0xFF337357),
      Color(0xFFFFD23F),
      Color(0xFF5E1675),
       Color(0xFFEE4266),
      Color(0xFF470000),

    ];
    return colors[index % colors.length];
  }
}