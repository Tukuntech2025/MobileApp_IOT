import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tukuntech/services/auth_service.dart';

class ProfileService {
  final String baseUrl = 'https://tukuntech-back.onrender.com/api/v1';
  final AuthService _authService = AuthService();

 
  Future<void> createProfile({
    required String firstName,
    required String lastName,
    required String dni,
    required int age,
    String? gender,
    String? bloodGroup,
    String? nationality,
    String? allergy,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No token found');

    final url = Uri.parse('$baseUrl/profiles');
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final body = json.encode({
      "firstName": firstName,
      "lastName": lastName,
      "dni": dni,
      "age": age,
      "gender": gender,
      "bloodGroup": bloodGroup,
      "nationality": nationality,
      "allergy": allergy,
    });

    print('🔵 Creating profile...');
    final response = await http.post(url, headers: headers, body: body);
    print('🔵 Create profile response status: ${response.statusCode}');
    print('🔵 Create profile response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('🟢 Profile created successfully');
    } else {
      print('🔴 Profile creation failed: ${response.body}');
      throw Exception('Profile creation failed: ${response.body}');
    }
  }

  
  Future<Map<String, dynamic>?> getMyProfile() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No token found');

    final url = Uri.parse('$baseUrl/profiles/me');
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    print('🔵 Getting my profile...');
    final response = await http.get(url, headers: headers);
    print('🔵 Get profile response status: ${response.statusCode}');
    print('🔵 Get profile response body: ${response.body}');

    if (response.statusCode == 200) {
      print('🟢 Profile retrieved successfully');
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
   
      print('🟡 Profile not found (user needs to create one)');
      return null;
    } else {
      print('🔴 Get profile failed: ${response.body}');
      throw Exception('Get profile failed: ${response.body}');
    }
  }

  
  Future<void> updateMyProfile({
    required String firstName,
    required String lastName,
    required String dni,
    required int age,
    String? gender,
    String? bloodGroup,
    String? nationality,
    String? allergy,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No token found');

    final url = Uri.parse('$baseUrl/profiles/me');
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final body = json.encode({
      "firstName": firstName,
      "lastName": lastName,
      "dni": dni,
      "age": age,
      "gender": gender,
      "bloodGroup": bloodGroup,
      "nationality": nationality,
      "allergy": allergy,
    });

    print('🔵 Updating profile...');
    final response = await http.put(url, headers: headers, body: body);
    print('🔵 Update profile response status: ${response.statusCode}');
    print('🔵 Update profile response body: ${response.body}');

    if (response.statusCode == 200) {
      print('🟢 Profile updated successfully');
    } else {
      print('🔴 Profile update failed: ${response.body}');
      throw Exception('Profile update failed: ${response.body}');
    }
  }


  Future<bool> hasProfile() async {
    try {
      final profile = await getMyProfile();
      return profile != null;
    } catch (e) {
      print('🔴 Error checking profile: $e');
      return false;
    }
  }
}