// services/conge_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../pages/models/conge.dart';

class CongeService {
  final String baseUrl = 'http://192.168.1.243:3000'; 

  Future<List<Conge>> fetchEmployeConges(String employeId) async {
    final response = await http.get(Uri.parse('$baseUrl/employe/$employeId/conges'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Conge.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load congés');
    }
  }
 
  Future<void> updateConge(String id, Map<String, dynamic> updatedCongeData) async {
    final url = '$baseUrl/conges/$id';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual token
      },
      body: jsonEncode(updatedCongeData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update conge: ${response.reasonPhrase}');
    }
  }
  
}
