import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intern_app/pages/notificationPage.dart';
import 'dart:convert';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String employeId;

  const CustomAppBar({
    super.key,
    required this.employeId,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount();
  }

  Future<void> _fetchNotificationCount() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.243:3000/notifications/employe/${widget.employeId}'),
    );

    if (response.statusCode == 200) {
      List<dynamic> notifications = jsonDecode(response.body);
      setState(() {
        notificationCount = notifications.length;
      });
    } else {
      // Handle error accordingly
      print('Failed to load notification count');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF1679AB),
      title: Row(
        children: [
          IconButton(
            icon: ImageIcon(AssetImage("assets/logoo.png")),
            iconSize: 70.0,
            onPressed: () {
              // Define any action you want when the logo is clicked
            },
            color: Colors.white,
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: ImageIcon(AssetImage("assets/bell.png")),
                iconSize: 25.0,
                color: const Color(0xFFEBF4F6),
                onPressed: () {
                  // Navigate to Notification Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationPage(employeId: widget.employeId),
                    ),
                  );
                },
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
