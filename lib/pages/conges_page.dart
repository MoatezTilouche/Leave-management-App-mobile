import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intern_app/pages/editLeaveRequest.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:intern_app/pages/LeaveRequest.dart';
import 'package:intern_app/pages/appBarr.dart';
import 'package:intern_app/pages/bottomBar.dart';
import 'package:intern_app/pages/models/conge.dart';
import 'package:intern_app/pages/sideBar.dart';
import 'package:intern_app/services/conge_service.dart';

class CongesListPage extends StatefulWidget {
  final String employeId;

  CongesListPage({required this.employeId});

  @override
  _CongesListPageState createState() => _CongesListPageState();
}

class _CongesListPageState extends State<CongesListPage> {
  late Future<List<Conge>> _congesFuture;
  final CongeService _congeService = CongeService();
  int _notificationCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _name = '';
  late String _email = '';
  late String _imageUrl = '';
late String _id='';
  @override
  void initState() {
    super.initState();
    _congesFuture = _congeService.fetchEmployeConges(widget.employeId);
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
          _name = userData['name'];
          _email = userData['email'];
          _id=userData['_id'];
        });
      } else {
        print('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
    }
  }

  void _incrementNotificationCount() {
    setState(() {
      _notificationCount++;
    });
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(parsedDate);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _showEditDialog(Conge conge) {
      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  EditLeaveRequestForm(conge: conge,)),
                    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
       employeId: _id
      ),
      drawer: AppDrawer(
        name: _name,
        email: _email,
        imageUrl: _imageUrl,
      ),
      backgroundColor: const Color(0xFFEBF4F6),
      body: FutureBuilder<List<Conge>>(
        future: _congesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Conge> conges = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: conges.length,
              itemBuilder: (context, index) {
                Conge conge = conges[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Type de Congé: ${conge.typeConge}",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                "Date de Début: ${_formatDate(conge.dateDebut)}",
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                "Date de Fin: ${_formatDate(conge.dateFin)}",
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Text(
                                    "Status: ",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  _buildStatusIcon(conge.statut),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if ((conge.typeConge == 'Maladie' && conge.statut == 'pending') || (conge.statut == 'pending'))
                          IconButton(
                            icon: Icon(Icons.edit, color: Color.fromARGB(255, 11, 11, 11)),
                            onPressed: () {
                              _showEditDialog(conge);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }
          return _buildShimmerLoading();
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
        selectedIndex: 1,
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color color;

    switch (status.toLowerCase()) {
      case 'accepted':
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case 'pending':
        iconData = Icons.pending;
        color = Colors.orange;
        break;
      case 'rejected':
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      default:
        iconData = Icons.help;
        color = Colors.black;
    }

    return Icon(
      iconData,
      color: color,
      size: 20,
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        );
      },
    );
  }
}
