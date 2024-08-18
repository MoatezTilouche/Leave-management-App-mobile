import 'package:flutter/material.dart';
import 'package:intern_app/pages/HomeProfile.dart';
import 'package:intern_app/pages/home.dart';
import 'package:intern_app/pages/login.dart';
import 'package:intern_app/services/api_service.dart';

class AppDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String imageUrl;

  AppDrawer(
      {Key? key,
      required this.name,
      required this.email,
      required this.imageUrl})
      : super(key: key);

  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: imageUrl.isEmpty
                  ? const AssetImage('assets/directeur.png') as ImageProvider
                  : NetworkImage(imageUrl),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1679AB),
            ),
          ),
          ListTile(
            leading: const ImageIcon(AssetImage("assets/user.png")),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Homeprofile()),
              );
            },
          ),
          ListTile(
            leading: ImageIcon(AssetImage("assets/croissance.png")),
            title: Text('Stats'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            },
          ),
          // ListTile(
          //   leading: ImageIcon(AssetImage("assets/bell.png")),
          //   title: Text('Notifications'),
          //   onTap: () {
          //     // Handle notifications tap
          //   },
          // ),
          ListTile(
            leading: ImageIcon(AssetImage("assets/se-deconnecter.png")),
            title: Text('Sign Out'),
            onTap: () async {
              await auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
