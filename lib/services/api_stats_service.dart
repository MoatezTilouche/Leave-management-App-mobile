import 'dart:convert';
import 'package:http/http.dart' as http;

class StatsService {
  final String baseUrl = 'http://192.168.1.243:3000';



Future<List<int>> fetchAcceptedLeavesByMonth(int year) async {
 
  final response = await http.get(
    Uri.parse('$baseUrl/stats/accepted-leaves-by-month/$year'),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {

    List<int> data = List<int>.from(jsonDecode(response.body));
    return data;
  } else {
    throw Exception('Failed to load data');
  }
}
     Future<int> fetchAcceptedLeavesCurrentMonth() async {
    final url = Uri.parse('$baseUrl/stats/accepted-leaves-current-month');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch accepted leaves');
    }
  }

  Future<int> fetchRefusedLeavesCurrentMonth() async {
    final url = Uri.parse('$baseUrl/stats/refused-leaves-current-month');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch refused leaves');
    }
  }

  Future<int> fetchPendingLeavesCurrentMonth() async {
    final url = Uri.parse('$baseUrl/stats/pending-leaves-current-month');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch pending leaves');
    }
  }


  Future<int> countAcceptedCongesForEmploye(String employeId) async {
    final response = await http.get(Uri.parse('$baseUrl/conges/count/accepted/$employeId'));

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load accepted congés count');
    }
  }

  Future<int> countPendingCongesForEmploye(String employeId) async {
    final response = await http.get(Uri.parse('$baseUrl/conges/count/pending/$employeId'));
     print(response.body);
     print(response.statusCode);
    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load pending congés count');
    }
  }

  Future<int> countRejectedCongesForEmploye(String employeId) async {
    final response = await http.get(Uri.parse('$baseUrl/conges/count/rejected/$employeId'));
   

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load rejected congés count');
    }
  }
    Future<int> countTotalDaysConges(String employeId) async {
    final response = await http.get(Uri.parse('$baseUrl/conges/total-days-taken-this-year/$employeId'));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load rejected congés count');
    }
  }

      Future<double> fetchAverageLeaveDays() async {
    final url = Uri.parse('$baseUrl/stats/average-leave-days');
    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetchAverage day leaves');
    }
  }
}
