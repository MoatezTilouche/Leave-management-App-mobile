import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:intern_app/pages/models/congee.dart';

class LeaveService {
  final String baseUrl = 'http://192.168.1.243:3000';

  Future<List<Congee>> fetchLeaves() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conges/accepted'),
      );
      print('Response Body: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data is List) {
          final leaves = await Future.wait(
            data.map((json) async {
              final conge = Congee.fromJson(json);
              final employeeName = await fetchEmployeeName(conge.employeeId);
              return conge.copyWith(employeeName: employeeName);
            }).toList(),
          );

          return leaves;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load leaves: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching leaves: $e');
      return [];
    }
  }

  Future<String> fetchEmployeeName(String employeeId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/employe/$employeeId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['name'] ??
            'Unknown'; // Provide a default value if 'name' is null
      } else {
        throw Exception(
            'Failed to load employee details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching employee name: $e');
      return 'Unknown'; // Provide a default value if there is an error
    }
  }
}
