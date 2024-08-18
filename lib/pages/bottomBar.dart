import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intern_app/pages/HomeProfile.dart';
import 'package:intern_app/pages/conges_page.dart';
import 'package:intern_app/pages/home.dart';

class DemoBottomAppBar extends StatefulWidget {
  const DemoBottomAppBar({
    Key? key,
    this.fabLocation = FloatingActionButtonLocation.centerDocked,
    this.shape = const CircularNotchedRectangle(),
    required this.scaffoldKey,
    required this.selectedIndex,
  }) : super(key: key);

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int selectedIndex;

  @override
  _DemoBottomAppBarState createState() => _DemoBottomAppBarState();
}

class _DemoBottomAppBarState extends State<DemoBottomAppBar> {
  late int _selectedIndex;
  String _id = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
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

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: widget.shape,
      color: Colors.white,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildTabItem(
              index: 0,
              icon: const ImageIcon(AssetImage("assets/home.png")),
              text: 'Home',
              navigateTo: const Home(),
            ),
            _buildTabItem(
              index: 1,
              icon: const ImageIcon(AssetImage("assets/menu.png")),
              text: 'Requests',
              navigateTo: CongesListPage(employeId: _id),
            ),
            const SizedBox(width: 40),
            _buildTabItem(
              index: 2,
              icon: const ImageIcon(AssetImage("assets/user.png")),
              text: 'Profile',
              navigateTo: Homeprofile(),
            ),
            _buildTabItem(
              index: 3,
              icon: const ImageIcon(AssetImage("assets/dots.png")),
              text: 'More',
              navigateTo: const Home(), // Replace with the desired page
              onTap: () => widget.scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required Widget icon,
    required String text,
    required Widget navigateTo,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            if (onTap != null) {
              onTap();
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => navigateTo),
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  color: isSelected ? const Color(0xFF4CB9E7) : Colors.grey,
                ),
                child: icon,
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF4CB9E7) : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
