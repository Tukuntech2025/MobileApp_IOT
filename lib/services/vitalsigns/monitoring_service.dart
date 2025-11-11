import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tukuntech/services/auth_service.dart';

class VitalMeasurement {
  final int id;
  final int patientId;
  final int deviceId;
  final int heartRate;
  final int oxygenLevel;
  final double temperature;
  final DateTime timestamp;

  VitalMeasurement({
    required this.id,
    required this.patientId,
    required this.deviceId,
    required this.heartRate,
    required this.oxygenLevel,
    required this.temperature,
    required this.timestamp,
  });

  factory VitalMeasurement.fromJson(Map<String, dynamic> json) {
    return VitalMeasurement(
      id: json['id'] ?? 0,
      patientId: json['patientId'] ?? 0,
      deviceId: json['deviceId'] ?? 0,
      heartRate: (json['heartRate'] ?? 0).toInt(),
      oxygenLevel: (json['oxygenLevel'] ?? 0).toInt(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class MonitoringService {
  final String baseUrl = 'https://tukuntech-back.onrender.com/api/v1';
  final AuthService _authService = AuthService();

  /// Obtiene la medición más reciente para un paciente
  Future<VitalMeasurement?> getLatestMeasurement(int patientId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No token found');

    final url = Uri.parse('$baseUrl/monitoring/patients/$patientId/measurements');
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    print('🔵 Getting latest measurement for patient: $patientId');
    final response = await http.get(url, headers: headers);
    print('🔵 Monitoring response status: ${response.statusCode}');
    print('🔵 Monitoring response body: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);

      // ✅ Caso 1: el backend devuelve una LISTA []
      if (data is List) {
        if (data.isEmpty) {
          print('🟡 No measurements in list');
          return null;
        }

        // Tomamos la ÚLTIMA medición de la lista
        final last = data.last;
        if (last is Map<String, dynamic>) {
          return VitalMeasurement.fromJson(last);
        } else {
          throw Exception('Invalid measurement item format');
        }
      }

      // ✅ Caso 2: por si acaso, si algún día cambia a objeto único {}
      if (data is Map<String, dynamic>) {
        return VitalMeasurement.fromJson(data);
      }

      throw Exception('Unexpected response format from monitoring API');
    } else if (response.statusCode == 404) {
      print('🟡 No measurements found for this patient');
      return null;
    } else {
      print('🔴 Failed to get measurements: ${response.body}');
      throw Exception('Failed to get measurements: ${response.body}');
    }
  }
}
