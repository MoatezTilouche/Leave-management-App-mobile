import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intern_app/pages/appBarr.dart';
import 'package:intern_app/pages/home.dart';

import 'package:intern_app/services/LeaveRequestApi.dart';

class Leaverequest extends StatefulWidget {
  @override
  State<Leaverequest> createState() => _LeaverequestState();
}

class _LeaverequestState extends State<Leaverequest> {
  final _formGlobalKey = GlobalKey<FormState>();
  String _email = '';
late String _id='';
  String? _selectedTypeConge;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String? _commentaire;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _selectedTypeConge = TypeConge[0]; 
    _dateDebut = DateTime.now(); 
    _dateFin = DateTime.now().add(Duration(days: 1));
    _commentaire = ''; 
  }

  List<String> TypeConge = [
    'Maladie',
    'Maternité',
    'Paternité',
    'Annuel',
    'Parental',
    'Formation',
    'Evénements familiaux',
    'Autre',
  ];

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
          _email = userData['email'];
          _id = userData['id'];
        });
      } else {
        print('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
    }
  }

  int _notificationCount = 0;

  void _incrementNotificationCount() {
    setState(() {
      _notificationCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF4F6),
      appBar: CustomAppBar(
        employeId: _id
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Demande de congés",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Sélectionner le type d’absence et ajouter une description de votre demande",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: _formGlobalKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Type de Congé',
                         labelStyle: const TextStyle(
                          color: Color(0xFF071952),
                          fontSize: 16,
                          ),
                        border: OutlineInputBorder(borderSide: BorderSide(color:const Color(0xFF071952)),),
                      ),
                      value: _selectedTypeConge,
                      onChanged: (value) => setState(() => _selectedTypeConge = value),
                      items: TypeConge.map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      validator: (value) => value == null ? 'Veuillez sélectionner un type de congé' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Date de Début',
                         labelStyle: const TextStyle(
                          color: Color(0xFF071952),
                          fontSize: 16,
                          ),
                        border: OutlineInputBorder(borderSide: BorderSide(color:const Color(0xFF071952)),),
                        suffixIcon: const Icon(Icons.calendar_month_outlined)
                     
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _dateDebut = date);
                        }
                      },
                      readOnly: true,
                      controller: TextEditingController(
                        text: _dateDebut != null ? "${_dateDebut!.day}/${_dateDebut!.month}/${_dateDebut!.year}" : '',
                      ),
                      validator: (value) => _dateDebut == null ? 'Veuillez sélectionner une date de début' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Date de Fin',
                          labelStyle: const TextStyle(
                          color: Color(0xFF071952),
                          fontSize: 16,
                          ),
                       border: OutlineInputBorder(borderSide: BorderSide(color:const Color(0xFF071952)),),
                          suffixIcon: const Icon(Icons.calendar_month_outlined)

                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(new FocusNode()); // To prevent opening the keyboard
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _dateFin = date);
                        }
                      },
                      readOnly: true,
                      controller: TextEditingController(
                        text: _dateFin != null ? "${_dateFin!.day}/${_dateFin!.month}/${_dateFin!.year}" : '',
                      ),
                      validator: (value) => _dateFin == null ? 'Veuillez sélectionner une date de fin' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Commentaire',
                        
                         labelStyle: const TextStyle(
                          color: Color(0xFF071952),
                          fontSize: 16,
                          ),
                        border: OutlineInputBorder(borderSide: BorderSide(color:const Color(0xFF071952)),),
                      ),
                      maxLines: 3,
                      onChanged: (value) => setState(() => _commentaire = value),
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un commentaire' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF37B7C3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: const Size(450, 40),
                      ),
                      onPressed: () async {
                        if (_formGlobalKey.currentState!.validate()) {
                          Leaverequestapi api = Leaverequestapi();
                          await api.requestLeave(
                            _email,
                            _selectedTypeConge!,
                            _dateDebut!,
                            _dateFin!,
                            _commentaire!,
                            DateTime.now(),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Home()),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Demande de congé envoyée avec succès!'),
                            ),
                          );

                          setState(() {
                            _selectedTypeConge = TypeConge[0];
                            _dateDebut = DateTime.now();
                            _dateFin = DateTime.now().add(Duration(days: 1));
                            _commentaire = '';
                          });
                        }
                      },
                      child: const Text('Envoyer la Demande',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          )),
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
