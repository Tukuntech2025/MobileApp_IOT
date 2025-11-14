import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tukuntech/core/base_screen.dart';
import 'package:tukuntech/services/auth_service.dart';
import 'package:tukuntech/services/vitalsigns/monitoring_service.dart';
import 'package:intl/intl.dart'; // 🆕 Necesario para formatear la fecha/hora

// Asumiendo que VitalMeasurement es una clase que representa la medición.

class VitalSignsPage extends StatefulWidget {
  const VitalSignsPage({super.key});

  @override
  State<VitalSignsPage> createState() => _VitalSignsPageState();
}

class _VitalSignsPageState extends State<VitalSignsPage> {
  final List<FlSpot> _spots = [];
  Timer? _chartTimer;
  Timer? _apiTimer;
  double _xValue = 0;

  final AuthService _authService = AuthService();
  final MonitoringService _monitoringService = MonitoringService();

  VitalMeasurement? _measurement; 
  // 🆕 Estado para las alertas cargadas de la API
  List<dynamic> _apiAlerts = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Timer para el mini "ECG" visual
    _chartTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        _xValue += 1;
        double yValue = 0;
        if (_xValue % 20 == 0) {
          yValue = 2;
        } else if (_xValue % 20 == 1) {
          yValue = -1;
        } else {
          yValue = 0;
        }
        _spots.add(FlSpot(_xValue, yValue));
        if (_spots.length > 50) _spots.removeAt(0);
      });
    });

    // Primera carga del API (incluye mediciones y alertas)
    _loadData();

    // Actualizar signos vitales y alertas cada 5 segundos
    _apiTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadData();
    });
  }
  
  // 🆕 Función unificada para cargar mediciones y alertas
  Future<void> _loadData() async {
    try {
      final int? patientId = await _authService.getUserId();
      // Usaremos el ID 21 para las alertas, como en HomePage, por consistencia.
      const int alertsPatientId = 21; 

      if (patientId == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 1. Cargar las mediciones
      final measurement = await _monitoringService.getLatestMeasurement(patientId);

      // 2. Cargar las alertas (usando el ID 21 fijo para la URL)
      final List<dynamic> fetchedAlerts =
          await _authService.getPatientAlerts(alertsPatientId);

      if (!mounted) return;

      // 3. Ordenar y limitar las alertas (3 más recientes)
      fetchedAlerts.sort((a, b) {
        final DateTime dateA = DateTime.parse(a['createdAt']);
        final DateTime dateB = DateTime.parse(b['createdAt']);
        return dateB.compareTo(dateA); 
      });
      final List<dynamic> limitedAlerts = fetchedAlerts.take(3).toList();


      setState(() {
        _measurement = measurement; 
        _apiAlerts = limitedAlerts; // 🆕 Actualiza el estado de las alertas
        _isLoading = false;
      });
      
      print('🟢 Alerts loaded: ${_apiAlerts.length}');

    } catch (e) {
      print('🔴 Error loading data (measurement or alerts): $e');
      if (!mounted) return;
      setState(() {
        _measurement = null; 
        _apiAlerts = [ // Muestra un mensaje de error en las alertas
          {'message': 'Error loading alerts', 'createdAt': DateTime.now().toIso8601String()}
        ];
        _isLoading = false;
      });
    }
  }
  
  // 🆕 Función para formatear el timestamp a hora
  String _formatTime(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp).toLocal();
      return DateFormat('hh:mm a').format(dateTime); 
    } catch (e) {
      return 'N/A';
    }
  }


  @override
  void dispose() {
    _chartTimer?.cancel();
    _apiTimer?.cancel();
    super.dispose();
  }

  Widget _miniChart(Color color) {
    return SizedBox(
      height: 30,
      child: LineChart(
        LineChartData(
          minX: _spots.isNotEmpty ? _spots.first.x : 0,
          maxX: _spots.isNotEmpty ? _spots.last.x : 50,
          minY: -2.5,
          maxY: 2.5,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _spots,
              isCurved: false,
              color: color,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vitalCard({
    required String bellAsset,
    required String iconAsset,
    required String value,
    required String unit,
    required String label,
    required bool dark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Colors.black : const Color(0xFFF0E8D5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: GoogleFonts.darkerGrotesque(
              fontSize: 14,
              color: dark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                bellAsset,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 16),
              Image.asset(
                iconAsset,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 16),
              Text(
                value,
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                unit,
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 16,
                  color: dark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _miniChart(dark ? Colors.white : Colors.black),
        ],
      ),
    );
  }

  // 🆕 Widget de tarjeta de alerta mejorado para mostrar la hora
  Widget _alertCard(String text, {required String time}) {
    // Busca y elimina el "Valores fuera de rango →" si existe, ya que el título de la sección es "Alerts"
    final displayMessage = text
        .replaceAll('Valores fuera de rango → ', '')
        .replaceAll('Valores fuera de rango →', '');

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.amber[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.warning, color: Colors.black, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayMessage,
              style: GoogleFonts.darkerGrotesque(
                fontSize: 18,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: GoogleFonts.darkerGrotesque(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 Función para construir la lista de alertas usando _apiAlerts
  List<Widget> _buildAlerts() {
    if (_apiAlerts.isEmpty) {
      return [
        Text(
          "No recent alerts",
          style: GoogleFonts.darkerGrotesque(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ];
    }

    return _apiAlerts.map<Widget>((alert) {
      final String message = alert['message'] ?? 'Unknown Alert';
      final String timestamp = alert['createdAt'] ?? DateTime.now().toIso8601String();
      final String time = _formatTime(timestamp);

      return _alertCard(message, time: time);
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    // Definimos los valores por defecto
    final int heartRate = _measurement?.heartRate ?? 0;
    final int oxygenLevel = _measurement?.oxygenLevel ?? 0;
    final double temperature = _measurement?.temperature ?? 0.0;

    return BaseScreen(
      title: "Vital Signs",
      currentIndex: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  _vitalCard(
                    bellAsset: "assets/noti2.png",
                    iconAsset: "assets/hearth.png",
                    value: heartRate.toString(), 
                    unit: "Bpm",
                    label: "Bpm",
                    dark: false,
                  ),
                  _vitalCard(
                    bellAsset: "assets/noti2.png",
                    iconAsset: "assets/SpO2.png",
                    value: "$oxygenLevel%",
                    unit: "",
                    label: "SpO₂",
                    dark: false,
                  ),
                  _vitalCard(
                    bellAsset: "assets/noti1.png",
                    iconAsset: "assets/temp2.png",
                    value: temperature.toStringAsFixed(1),
                    unit: "°C",
                    label: "Temp",
                    dark: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Alerts",
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 🆕 Usa el nuevo _buildAlerts
                  ..._buildAlerts(),
                ],
              ),
      ),
    );
  }
}