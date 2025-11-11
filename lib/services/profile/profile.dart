import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tukuntech/services/auth_service.dart';

class ProfileService {
  static const String _baseUrl = 'https://tukuntech-back.onrender.com/api/v1';
  final AuthService _authService = AuthService();

  /// 🔑 Obtener token JWT desde AuthService
  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No se encontró el token. El usuario no ha iniciado sesión.');
    }
    return token;
  }

  /// 🟢 GET /profiles/me
  Future<Map<String, dynamic>> getMyProfile() async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/profiles/me');

    print('🔵 GET $uri');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('🔵 GET /profiles/me -> status: ${response.statusCode}');
    print('🔵 Response: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception('Token inválido o sesión expirada.');
    } else {
      throw Exception(
        'Error obteniendo perfil. Código ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// 🟡 PUT /profiles/me
  ///
  /// Body esperado:
  /// {
  ///   "firstName": "string",
  ///   "lastName": "string",
  ///   "dni": "string",
  ///   "age": 120,
  ///   "gender": "MALE",
  ///   "bloodGroup": "O_POSITIVE",
  ///   "nationality": "PERUVIAN",
  ///   "allergy": "PENICILLIN"
  /// }
  Future<void> updateMyProfile({
    required String firstName,
    required String lastName,
    required String dni,
    required int age,
    required String? gender,
    String? bloodGroup,
    String? nationality,
    String? allergy,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/profiles/me');

    final Map<String, dynamic> body = {
      'firstName': firstName,
      'lastName': lastName,
      'dni': dni,
      'age': age,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'nationality': nationality,
      'allergy': allergy,
    };

    print('🟡 PUT $uri');
    print('🟡 Request body: ${jsonEncode(body)}');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('🟡 PUT /profiles/me -> status: ${response.statusCode}');
    print('🟡 Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('🟢 Perfil actualizado correctamente');
    } else if (response.statusCode == 400) {
      throw Exception('Datos inválidos: ${response.body}');
    } else if (response.statusCode == 401) {
      throw Exception('Token inválido o sesión expirada.');
    } else {
      throw Exception(
        'Error actualizando perfil. Código ${response.statusCode}: ${response.body}',
      );
    }
  }
}
