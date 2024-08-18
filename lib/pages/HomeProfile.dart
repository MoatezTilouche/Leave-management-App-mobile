import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intern_app/pages/LeaveRequest.dart';
import 'package:intern_app/pages/appBarr.dart';
import 'dart:convert';
import 'package:intern_app/pages/bottomBar.dart';
import 'package:intern_app/pages/sideBar.dart';
import 'package:intern_app/services/api_stats_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Homeprofile extends StatefulWidget {
  const Homeprofile({Key? key}) : super(key: key);

  @override
  State<Homeprofile> createState() => _HomeprofileState();
}

class _HomeprofileState extends State<Homeprofile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _name = '';
  late String _id = '';
  late String _dep = '';
  late String _email = '';
  late String _role = '';
  late String _imageUrl = '';
  late String _pass = '';
  late int age = 0;
  int _soldeConges = 0;
  int _soldeMaladie = 0;
  DateTime _dateInscription = DateTime.now();
  String _sexe = '';
  late Future<int> acceptedConges = Future.value(0);
  late Future<int> pendingConges = Future.value(0);
  late Future<int> rejectedConges = Future.value(0);
  final StatsService statsService = StatsService();
  int _notificationCount = 0;

  bool _isLoading = true; // Add a loading flag

  @override
  void initState() {
    super.initState();
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
          _dep = userData['department'];
          _email = userData['email'];
          _role = userData['role'];
          _imageUrl = userData['photo'] ?? '';
          _id = userData['_id'];
          _pass = userData['password'];
          age = userData['age'];
          _soldeConges = userData['soldeConges'];
          _soldeMaladie = userData['soldeMaladie'];
          _dateInscription = DateTime.parse(userData['dateInscription']);
          _sexe = userData['sexe'];

          acceptedConges = statsService.countAcceptedCongesForEmploye(_id);
          pendingConges = statsService.countPendingCongesForEmploye(_id);
          rejectedConges = statsService.countRejectedCongesForEmploye(_id);
          _isLoading = false;
          isImageLoaded = true;
          print(isImageLoaded);
        });
      } else {
        print('Failed to load user profile: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _incrementNotificationCount() {
    setState(() {
      _notificationCount++;
    });
  }

  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 8);

    if (image != null) {
      await _uploadImage(File(image.path));
    }
  }

  bool isImageLoaded = false;

  Future<void> _uploadImage(File imageFile) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.243:3000/employe/$_id/photo'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print('Response content: $responseBody');

        final String newImageUrl = responseBody['photo'] ?? '';

        setState(() {
          _imageUrl = newImageUrl;
          print("IMAGE IS SAVED");
        });

        print('New image URL: $_imageUrl');
      } else {
        print('Failed to upload image: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
    }
  }

  Future<void> _updateUserProfile(String field, String value) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final Map<String, dynamic> updatedData = {
      'email': _email,
      'name': _name,
      'department': _dep,
      'role': _role,
      'password': _pass,
      'photo': _imageUrl,
      'age': age,
      'sexe': _sexe,
      'dateInscription': _dateInscription,
      'soldeConges': _soldeConges,
      'soldeMaladie': _soldeMaladie
    };

    try {
      final response = await http.put(
        Uri.parse('http://192.168.1.243:3000/employe/$_id'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Employee Updated Successfully");
      } else {
        print('Failed to update user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
    }
  }

  Widget _buildNonEditableField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        enabled: false,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String value) {
    final _formKey = GlobalKey<FormFieldState>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          TextFormField(
            key: _formKey,
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $label';
              }
              return null;
            },
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final text = _formKey.currentState?.value;
                  if (text != null) {
                    if (label == "Nom") {
                      await _updateUserProfile("name", text);
                      setState(() {
                        _name = text;
                      });
                    } else if (label == "Email") {
                      await _updateUserProfile("email", text);
                      setState(() {
                        _email = text;
                      });
                    } else if (label == "Department") {
                      await _updateUserProfile("department", text);
                      setState(() {
                        _dep = text;
                      });
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            color: const Color(0xFF1679AB),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 45.0,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  width: 300,
                  height: 160,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 100,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 30,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 60,
                                height: 10,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 30,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 60,
                                height: 10,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 30,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 60,
                                height: 10,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: FractionallySizedBox(
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 150,
                        height: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 200,
                              height: 20,
                              color: Colors.white,
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF37B7C3))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Change',
                  style: TextStyle(color: Color(0xFF37B7C3))),
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateUserPassword(
                    currentPasswordController.text, newPasswordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserPassword(
      String currentPassword, String newPassword) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final Map<String, dynamic> passwordData = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };

    try {
      final response = await http.put(
        Uri.parse('http://192.168.1.243:3000/employe/$_id/change-password'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(passwordData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Password Updated Successfully");
      } else {
        print('Failed to update password: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEBF4F6),
      appBar: CustomAppBar(employeId: _id),
      drawer: AppDrawer(
        name: _name,
        email: _email,
        imageUrl: _imageUrl,
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    color: const Color(0xFF1679AB),
                    child: Column(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 45.0,
                                backgroundImage: _image != null
                                    ? FileImage(_image!)
                                    : _imageUrl.isNotEmpty
                                        ? NetworkImage(_imageUrl)
                                        : const AssetImage(
                                                'assets/directeur.png')
                                            as ImageProvider,
                              ),
                              Positioned(
                                bottom: -8,
                                right: -5,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      /*   borderRadius:
                                              BorderRadius.circular(50),
                                          color: Colors.grey.withOpacity(0.4), */
                                      ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF4F6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            width: 300,
                            height: 160,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 14),
                                Text(
                                  _name,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  _dep,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    color: Color.fromARGB(255, 107, 104, 104),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          FutureBuilder<int>(
                                            future: acceptedConges,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return const Text('Erreur');
                                              } else {
                                                return Text(
                                                  snapshot.data.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          const Text(
                                            "Demandes ",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            "acceptés",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          FutureBuilder<int>(
                                            future: pendingConges,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return const Text('Erreur');
                                              } else {
                                                return Text(
                                                  snapshot.data.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          const Text(
                                            "Demandes",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            " en attente",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          FutureBuilder<int>(
                                            future: rejectedConges,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return const Text('Erreur');
                                              } else {
                                                return Text(
                                                  snapshot.data.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          const Text(
                                            "Demandes",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            " Refusés",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                "Vos Coordonnées",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 20,
                                          ),
                                          Expanded(
                                              child: _buildEditableField(
                                                  "Nom", _name)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.email,
                                            size: 20,
                                          ),
                                          Expanded(
                                              child: _buildEditableField(
                                                  "Email", _email)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.business,
                                            size: 20,
                                          ),
                                          Expanded(
                                              child: _buildNonEditableField(
                                                  "Department", _dep)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.supervisor_account,
                                            size: 20,
                                          ),
                                          Expanded(
                                              child: _buildNonEditableField(
                                                  "Role", _role)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.cake,
                                            size: 20,
                                          ),
                                          Expanded(
                                              child: _buildEditableField(
                                                  "Age", age.toString())),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                _sexe == 'male'
                                                    ? const Icon(Icons.male,
                                                        size: 20)
                                                    : const Icon(
                                                        Icons.female,
                                                        size: 20,
                                                      ),
                                                Expanded(
                                                    child:
                                                        _buildNonEditableField(
                                                            "Sexe", _sexe)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.money_off, size: 20),
                                          Expanded(
                                              child: _buildNonEditableField(
                                                  "Solde Conges",
                                                  _soldeConges.toString())),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.medical_services,
                                              size: 20),
                                          Expanded(
                                              child: _buildNonEditableField(
                                                  "Solde Maladie",
                                                  _soldeMaladie.toString())),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 20),
                                          Expanded(
                                              child: _buildNonEditableField(
                                                  "Date Inscription",
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(
                                                          _dateInscription))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: _changePassword,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF4CB9E7),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                child: const Text("Change Password"),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Leaverequest()),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF4CB9E7),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DemoBottomAppBar(
        scaffoldKey: _scaffoldKey,
        selectedIndex: 2,
      ),
    );
  }
}
