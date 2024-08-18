import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intern_app/pages/appBarr.dart';
import 'package:intern_app/pages/home.dart';
import 'package:intern_app/pages/models/conge.dart';
import 'package:intern_app/pages/sideBar.dart';
import 'package:intern_app/services/conge_service.dart';

class EditLeaveRequestForm extends StatefulWidget {
  final Conge conge;

  EditLeaveRequestForm({required this.conge});

  @override
  _EditLeaveRequestFormState createState() => _EditLeaveRequestFormState();
}

class _EditLeaveRequestFormState extends State<EditLeaveRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedTypeConge;
  late DateTime _dateDebut;
  late DateTime _dateFin;
  late String _commentaire;
  late String? _attestation;
  late String conge_id;
  int _notificationCount = 0;
  late String _id='';

  final CongeService _congeService = CongeService();

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

  @override
  void initState() {
    super.initState();
    _selectedTypeConge = widget.conge.typeConge;
    _dateDebut = DateTime.parse(widget.conge.dateDebut);
    _dateFin = DateTime.parse(widget.conge.dateFin);
    _commentaire = widget.conge.commentaire ?? '';
    _attestation = widget.conge.attestation;
    conge_id = widget.conge.id;
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
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _uploadAttestation(File(image.path));
    }
  }

  void _incrementNotificationCount() {
    setState(() {
      _notificationCount++;
    });
  }

  Future<void> _uploadAttestation(File attFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.243:3000/conges/$conge_id/attestation'),
    );

    request.files
        .add(await http.MultipartFile.fromPath('attestation', attFile.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print('Response content: $responseBody');

        final String newAttestationurl = responseBody['attestation'] ?? '';

        setState(() {
          _attestation = newAttestationurl;
        });
        print('New Attestation URL: $_attestation');
      } else {
        print('Failed to upload attestation: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error uploading attestation: $e');
    }
  }

  Future<void> _updateLeaveRequest() async {
    final Map<String, dynamic> updatedCongeData = {
      'typeConge': _selectedTypeConge,
      'dateDebut': _dateDebut.toIso8601String(),
      'dateFin': _dateFin.toIso8601String(),
      'commentaire': _commentaire,
      'attestation': _attestation,
    };

    try {
      await _congeService.updateConge(widget.conge.id, updatedCongeData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Demande de congé mise à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la mise à jour: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
       employeId: _id
      ),
      backgroundColor: const Color(0xFFEBF4F6),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Type de Congé',
                      labelStyle: TextStyle(
                        color: Color(0xFF071952),
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTypeConge,
                    onChanged: (value) =>
                        setState(() => _selectedTypeConge = value!),
                    items: TypeConge.map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        )).toList(),
                    validator: (value) => value == null
                        ? 'Veuillez sélectionner un type de congé'
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date de Début',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text:
                          "${_dateDebut.day}/${_dateDebut.month}/${_dateDebut.year}",
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dateDebut,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => _dateDebut = date);
                      }
                    },
                    validator: (value) => _dateDebut == null
                        ? 'Veuillez sélectionner une date de début'
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date de Fin',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text:
                          "${_dateFin.day}/${_dateFin.month}/${_dateFin.year}",
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dateFin,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => _dateFin = date);
                      }
                    },
                    validator: (value) => _dateFin == null
                        ? 'Veuillez sélectionner une date de fin'
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Commentaire',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _commentaire,
                    maxLines: 3,
                    onChanged: (value) => setState(() => _commentaire = value),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez entrer un commentaire'
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  if (_selectedTypeConge == 'Maladie') ...[
                    Row(
                      children: <Widget>[
                        const Text("Upload une attestation"),
                        IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload_file),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    if (_attestation != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            _attestation!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Attestation added successfully",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16.0),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF4CB9E7),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateLeaveRequest().then((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                          );
                        });
                      }
                    },
                    child: const Text('Mettre à jour'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
