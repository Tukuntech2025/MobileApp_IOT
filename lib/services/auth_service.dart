import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://tukuntech-back.onrender.com/api/v1';

  
  Future<void> registerUser(String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "email": email,
      "password": password,
      "role": role, 
    });

    print('🔵 Attempting registration for: $email with role: $role');
    final response = await http.post(url, headers: headers, body: body);
    print('🔵 Registration response status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('🟢 User registered successfully');
    } else {
      print('🔴 Registration failed: ${response.body}');
      throw Exception('Registration failed: ${response.body}');
    }
  }

  
  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "email": email,
      "password": password,
    });

    print('🔵 Sending login request to: $url');
    print('🔵 Request body: $body');
    
    final response = await http.post(url, headers: headers, body: body);
    
    print('🔵 Login response status code: ${response.statusCode}');
    print('🔵 Login response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      
      
      if (!data.containsKey('accessToken')) {
        print('🔴 Response does not contain accessToken');
        throw Exception('Invalid response format: missing accessToken');
      }
      
      String token = data['accessToken'];
      print('🟢 Token received: ${token.substring(0, 20)}...');

    
      await _saveToken(token);
      
    
      if (data.containsKey('user') && data['user'].containsKey('id')) {
        int userId = data['user']['id'];
        await _saveUserId(userId);
        print('🟢 UserId saved: $userId');
      }
      
      
      if (data.containsKey('user') && data['user'].containsKey('roles')) {
        List<String> roles = List<String>.from(data['user']['roles']);
        await _saveRoles(roles);
        print('🟢 Roles saved: $roles');
      }
      
      print('🟢 Login successful');

    } else if (response.statusCode == 401) {
      print('🔴 Invalid credentials (401)');
      throw Exception('Invalid credentials');
    } else if (response.statusCode == 400) {
      print('🔴 Bad request (400): ${response.body}');
      throw Exception('Bad request');
    } else if (response.statusCode == 500) {
      var data = json.decode(response.body);
      String message = data['message'] ?? '';
      
      if (message.contains('Invalid email or password') || message.contains('401 UNAUTHORIZED')) {
        print('🔴 Invalid credentials (500 with auth error)');
        throw Exception('Invalid credentials');
      }
      
      print('🔴 Server error (500): ${response.body}');
      throw Exception('Server error');
    } else {
      print('🔴 Login failed with status ${response.statusCode}: ${response.body}');
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<List<dynamic>> getPatientAlerts(int patientId) async {
    final token = await getToken();
    if (token == null) {
      print('🔴 Error: Token not found for alerts request.');
      throw Exception('User not logged in or token expired.');
    }

    final url = Uri.parse('$baseUrl/monitoring/patients/$patientId/alerts');
    print('🔵 Sending alerts request to: $url');

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    try {
      final response = await http.get(url, headers: headers);
      print('🔵 Alerts response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final String jsonString = utf8.decode(response.bodyBytes);
        return json.decode(jsonString);
      } else {
        print('🔴 Failed to load alerts: ${response.body}');
        throw Exception(
            'Failed to load patient alerts. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴 Error during getPatientAlerts: $e');
      rethrow;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('🔵 Token stored in SharedPreferences');
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    print('🔵 UserId stored in SharedPreferences');
  }

  Future<void> _saveRoles(List<String> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('roles', roles);
    print('🔵 Roles stored in SharedPreferences');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    print('🔵 Getting userId from storage: ${userId ?? "Not found"}');
    return userId;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('🔵 Getting token from storage: ${token != null ? "Found" : "Not found"}');
    return token;
  }

  Future<List<String>> getRoles() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? roles = prefs.getStringList('roles');
    print('🔵 Getting roles from storage: ${roles ?? []}');
    return roles ?? [];
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('roles');
    await prefs.remove('userId');
    print('🔵 Token, roles and userId removed from storage');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasToken = prefs.containsKey('token');
    print('🔵 Checking if logged in: $hasToken');
    return hasToken;
  }
}