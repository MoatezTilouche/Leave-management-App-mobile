import 'package:http/http.dart' as http;
import 'dart:convert';

class Leaverequestapi {
  final String baseUrl = 'http://192.168.1.243:3000/conges/new';

  Future<void> requestLeave(String email, String type, DateTime dateDebut, DateTime dateFin, String commentaire, DateTime dateDemmande) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'typeConge': type,
          'dateDebut': dateDebut.toIso8601String(),
          'dateFin': dateFin.toIso8601String(),
          'commentaire': commentaire,
          'dateDemmande': dateDemmande.toIso8601String(),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('Leave request sent successfully!');
      } else {
        print('Error sending leave request: ${response.statusCode}');
        if (response.statusCode == 400) {
          print('Bad request');
        } else if (response.statusCode == 401) {
          print('Unauthorized');
        } else if (response.statusCode == 500) {
          print('Internal server error');
        }
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }
}
