import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intern_app/services/pie_chart_service.dart';

class LeaveTypeStatisticsPage extends StatefulWidget {
  const LeaveTypeStatisticsPage({super.key});

  @override
  State<LeaveTypeStatisticsPage> createState() =>
      _LeaveTypeStatisticsPageState();
}

class _LeaveTypeStatisticsPageState extends State<LeaveTypeStatisticsPage> {
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
    return Scaffold(
      body: leaveStatistics.isEmpty
          ? const Center(child: CircularProgressIndicator.adaptive())
          : PieChartSample(data: leaveStatistics),
    );
  }
}

class PieChartSample extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const PieChartSample({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: 220,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event,
                    PieTouchResponse? pieTouchResponse) {},
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: showingSections(),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(data.length, (i) {
      final Map<String, dynamic> item = data[i];
      final isTouched = i == 0; 
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final int percentage = item['percentage'].toInt();

      return PieChartSectionData(
        color: getColor(i),
        value: percentage.toDouble(),
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
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

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
