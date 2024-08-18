import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/models/usernotification.dart';


class NotificationService {
  final String baseUrl = 'http://192.168.1.243:3000/notifications';

  Future<List<UserNotification>> fetchNotificationsForEmployee(String employeId) async {
    final response = await http.get(Uri.parse('$baseUrl/employe/$employeId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => UserNotification.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
