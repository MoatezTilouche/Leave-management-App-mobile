import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intern_app/pages/appBarr.dart';
import 'package:intern_app/pages/models/congee.dart';
import 'package:intern_app/services/calendar_service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class LeaveCalendar extends StatefulWidget {
  @override
  _LeaveCalendarState createState() => _LeaveCalendarState();
}

class _LeaveCalendarState extends State<LeaveCalendar> {
  late LeaveService leaveService;
  late Future<List<Congee>> futureLeaves;
  List<Meeting> meetings = [];
  DateTime firstDay = DateTime.utc(2024, 7, 1);
  DateTime lastDay = DateTime.utc(2026, 12, 31);
  late DateTime focusedDay;
  int _notificationCount = 0;
  late String _id = '';

  void _incrementNotificationCount() {
    setState(() {
      _notificationCount++;
    });
  }

  final Map<String, Color> leaveTypeColors = {
    'Maladie': Colors.red,
    'Maternité': Colors.pink,
    'Parental': Colors.green,
    'Formation': const Color(0xFF004B95),
    'Evénements familiaux': const Color(0xFF8481DD),
    'Paternité': const Color(0xFFF0AB00),
    'Autre': const Color(0xFF009596),
    'Annuel': const Color(0xFF470000),
  };

  @override
  void initState() {
    super.initState();
    leaveService = LeaveService();
    futureLeaves = _fetchAndProcessLeaves();
    focusedDay = DateTime.now();
    _validateFocusedDay();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.243:3000/auth/profile'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
          _id = userData['_id'];
        });
      } else {
        print('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
    }
  }

  Future<List<Congee>> _fetchAndProcessLeaves() async {
    try {
      List<Congee> leaves = await leaveService.fetchLeaves();
      print('Fetched leaves: $leaves'); // Debugging
      _processLeavesToMeetings(leaves);
      return leaves;
    } catch (e) {
      print('Error fetching leaves: $e'); // Debugging
      return [];
    }
  }

  void _processLeavesToMeetings(List<Congee> leaves) {
    final List<Meeting> events = [];

    for (var leave in leaves) {
      DateTime startDate = DateTime.parse(leave.dateDebut);
      DateTime endDate = DateTime.parse(leave.dateFin);

      print('Processing leave: ${leave.typeConge} from $startDate to $endDate');

      events.add(Meeting(
        '${leave.typeConge} (${leave.employeeName})',
        startDate,
        endDate,
        leaveTypeColors[leave.typeConge] ?? const Color.fromARGB(90, 95, 8, 8),
        false,
      ));
    }

    setState(() {
      meetings = events;
    });
    print("hello");
  }

  void _validateFocusedDay() {
    if (focusedDay.isBefore(firstDay)) {
      focusedDay = firstDay;
    } else if (focusedDay.isAfter(lastDay)) {
      focusedDay = lastDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF4F6),
      appBar: CustomAppBar(employeId: _id),
      body: FutureBuilder<List<Congee>>(
        future: futureLeaves,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Accepted Leaves Calendar",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 500.0,
                    child: SfCalendar(
                      view: CalendarView.month,
                      dataSource: MeetingDataSource(meetings),
                      todayHighlightColor: const Color(0xFF37B7C3),
                      monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment,
                        showTrailingAndLeadingDates: true,
                        numberOfWeeksInView: 4,
                        monthCellStyle: MonthCellStyle(
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                      onTap: (details) {
                        print('Tapped: ${details.date}');
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No leaves found.'));
          }
        },
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
    print('Appointments initialized: $appointments'); // Debugging
  }

  @override
  DateTime getStartTime(int index) {
    print(
        'Start Time for index $index: ${appointments![index].from}'); // Debugging
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    print('End Time for index $index: ${appointments![index].to}'); // Debugging
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    print(
        'Subject for index $index: ${appointments![index].eventName}'); // Debugging
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    print(
        'Color for index $index: ${appointments![index].background}'); // Debugging
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    print(
        'Is All Day for index $index: ${appointments![index].isAllDay}'); // Debugging
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
