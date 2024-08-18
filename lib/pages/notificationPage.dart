import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intern_app/pages/LeaveRequest.dart';
import 'package:intern_app/pages/appBarr.dart';
import 'package:intern_app/pages/bottomBar.dart';
import 'package:intern_app/pages/models/usernotification.dart';
import 'package:intern_app/services/notification_service.dart';
import 'package:http/http.dart' as http;

class NotificationPage extends StatefulWidget {
  final String employeId;

  NotificationPage({required this.employeId});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<UserNotification>> _notifications;
  late String _id = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load the user profile to get the employee ID
    NotificationService notificationService = NotificationService();
    _notifications = notificationService.fetchNotificationsForEmployee(widget.employeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(employeId: _id),
      body: FutureBuilder<List<UserNotification>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications available.'));
          } else {
            // Trier les notifications par date décroissante
            List<UserNotification> sortedNotifications = snapshot.data!;
            sortedNotifications.sort((a, b) => b.dateNotif.compareTo(a.dateNotif));

            return ListView(
              children: sortedNotifications.map((notification) {
                return _buildNotificationItem(
                  notification.nameNotif,
                  notification.contenuNotif,
                  _formatDate(notification.dateNotif),
                  notification.photo,
                  notification.photo != null ? Icons.person : Icons.message,
                  Colors.blue,
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Leaverequest()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF4CB9E7),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DemoBottomAppBar(
        scaffoldKey: _scaffoldKey,
        selectedIndex: 0,
      ),
    );
  }

  Widget _buildNotificationItem(String name, String message, String time,
      String? photoUrl, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300],
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : AssetImage("assets/notif.png") as ImageProvider,
            onBackgroundImageError: (exception, stackTrace) {
              print('Error loading image: $exception');
            },
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4.0),
                Text(message, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 8.0),
          Icon(icon, color: iconColor),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inMinutes < 60) {
      return 'Just Now';
    } else if (now.difference(date).inDays == 0) {
      return '${date.hour}:${date.minute}';
    } else if (now.difference(date).inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
