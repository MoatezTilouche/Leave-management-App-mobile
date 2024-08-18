import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.1.243:3000';

  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['access_token'];
      await _storage.write(key: 'jwt_token', value: token);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _storage.delete(key: 'jwt_token');
    prefs.clear();
  }

  Future<Map<String, dynamic>?> loadUserProfile() async {
    final token = await _storage.read(key: 'jwt_token');

    // if (token == null) {
    //   throw Exception('No token found');
    // }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      ;
      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return userData;
      } else {
        print('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
    }
    return null;
  }
}
