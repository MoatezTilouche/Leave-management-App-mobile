import 'dart:convert';
import 'package:http/http.dart' as http;

class PieChartService {
  static const baseUrl = 'http://192.168.1.243:3000/conges/statistics/leave-percentages'; 

  Future<List<Map<String, dynamic>>> fetchLeaveStatistics() async {
    final response = await http.get(Uri.parse('$baseUrl'));
  
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load leave statistics');
    }
  }
}
