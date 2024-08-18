import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intern_app/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Forrm extends StatefulWidget {
  const Forrm({Key? key}) : super(key: key);

  @override
  State<Forrm> createState() => _ForrmState();
}

class _ForrmState extends State<Forrm> {
  final _formGlobalKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  String _email = '';
  String _password = '';

  Future<void> _login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_formGlobalKey.currentState!.validate()) {
      _formGlobalKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.243:3000/auth/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode(<String, String>{
            'email': _email,
            'password': _password,
          }),
        );

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          await _storage.write(
              key: 'token', value: responseBody['access_token']);
          prefs.setString("token", responseBody['access_token']);
          prefs.setBool("isAuth", true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unexpected error occurred')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to the server: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.243:3000/auth/forgot-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(<String, String>{
          'email': _emailController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('A new password has been sent to your email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sending the new password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Email address",
                    labelStyle: const TextStyle(
                        color: Color(0xFF638889),
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                    hintText: "Enter your email",
                    hintStyle:
                        const TextStyle(color: Color(0xFF638889), fontSize: 12),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFFEBF4F6)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon:
                        const Icon(Icons.email, color: Color(0xFF071952)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 48),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send'),
              onPressed: _isLoading ? null : _forgotPassword,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Form(
              key: _formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Email address",
                      labelStyle: const TextStyle(
                          color: Color(0xFF638889),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                      hintText: "Enter your email",
                      hintStyle: const TextStyle(
                          color: Color(0xFF638889), fontSize: 12),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFEBF4F6)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon:
                          const Icon(Icons.email, color: Color(0xFF071952)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 48),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'You must fill your email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Password",
                      labelStyle: const TextStyle(
                          color: Color(0xFF638889),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                      hintText: "Enter your password",
                      hintStyle: const TextStyle(
                          color: Color(0xFF638889), fontSize: 12),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFEBF4F6)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon:
                          const Icon(Icons.lock, color: Color(0xFF071952)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF071952),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 48),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'You must fill your password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF37B7C3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(450, 40),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await _showForgotPasswordDialog();
                    },
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
