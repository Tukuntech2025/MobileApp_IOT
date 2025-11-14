import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tukuntech/services/auth_service.dart';

class SupportService {
  final String baseUrl = 'https://tukuntech-back.onrender.com/api/v1';
  final AuthService _authService = AuthService();

  // 🆕 Crear ticket de soporte
  Future<Map<String, dynamic>> createTicket({
    required String name,
    required String email,
    required String subject,
    required String description,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No token found');

    final url = Uri.parse('$baseUrl/support/tickets');
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final body = json.encode({
      "name": name,
      "email": email,
      "subject": subject,
      "description": description,
    });

    print('🔵 Creating support ticket...');
    final response = await http.post(url, headers: headers, body: body);
    print('🔵 Create ticket response status: ${response.statusCode}');
    print('🔵 Create ticket response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('🟢 Ticket created successfully');
      return json.decode(response.body);
    } else {
      print('🔴 Ticket creation failed: ${response.body}');
      throw Exception('Ticket creation failed: ${response.body}');
    }
  }

  // 🆕 Obtener mis tickets
  Future<List<Map<String, dynamic>>> getMyTickets() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No token found');

    final url = Uri.parse('$baseUrl/support/my-tickets');
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    print('🔵 Getting my tickets...');
    final response = await http.get(url, headers: headers);
    print('🔵 Get tickets response status: ${response.statusCode}');
    print('🔵 Get tickets response body: ${response.body}');

    if (response.statusCode == 200) {
      print('🟢 Tickets retrieved successfully');
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else if (response.statusCode == 404) {
      // No tiene tickets todavía
      print('🟡 No tickets found for user');
      return [];
    } else {
      print('🔴 Get tickets failed: ${response.body}');
      throw Exception('Get tickets failed: ${response.body}');
    }
  }
}