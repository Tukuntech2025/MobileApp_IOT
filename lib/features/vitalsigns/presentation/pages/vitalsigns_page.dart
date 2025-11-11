import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tukuntech/core/base_screen.dart';
import 'package:tukuntech/services/auth_service.dart';
import 'package:tukuntech/services/vitalsigns/monitoring_service.dart';


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
  bool _isLoading = true;
  String? _error;

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

    // Primera carga del API
    _loadMeasurement();

    // Actualizar signos vitales cada 5 segundos (ajusta si quieres)
    _apiTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadMeasurement();
    });
  }

  Future<void> _loadMeasurement() async {
    try {
      final int? patientId = await _authService.getUserId();

      if (patientId == null) {
        setState(() {
          _error = 'No patient id found';
          _isLoading = false;
        });
        return;
      }

      final measurement = await _monitoringService.getLatestMeasurement(patientId);

      if (!mounted) return;

      setState(() {
        _measurement = measurement;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      print('🔴 Error loading measurement: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Error loading vital signs';
        _isLoading = false;
      });
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

  Widget _alertCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.amber[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.black, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.darkerGrotesque(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAlerts() {
    final List<Widget> alerts = [];

    if (_measurement == null) return alerts;

    final m = _measurement!;

    // Reglas simples de ejemplo (ajusta según tu lógica clínica)
    if (m.oxygenLevel < 92) {
      alerts.add(_alertCard("Low oxygenation (${m.oxygenLevel}%)"));
    }
    if (m.heartRate > 120) {
      alerts.add(_alertCard("High heart rate (${m.heartRate} bpm)"));
    }
    if (m.temperature > 37.5) {
      alerts.add(_alertCard("High temperature (${m.temperature.toStringAsFixed(1)} °C)"));
    }

    if (alerts.isEmpty) {
      alerts.add(
        Text(
          "No alerts",
          style: GoogleFonts.darkerGrotesque(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      );
    }

    return alerts;
  }

  @override
Widget build(BuildContext context) {
  return BaseScreen(
    title: "Vital Signs",
    currentIndex: 1,
    child: Padding(
      padding: const EdgeInsets.all(16),

      // 👇 AQUÍ empieza lo que debes pegar
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 18,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : (_measurement == null)
                  ? Center(
                      child: Text(
                        'No vital signs recorded yet for this patient.',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView(
                      children: [
                        _vitalCard(
                          bellAsset: "assets/noti2.png",
                          iconAsset: "assets/hearth.png",
                          value: _measurement!.heartRate.toString(),
                          unit: "Bpm",
                          label: "Bpm",
                          dark: false,
                        ),
                        _vitalCard(
                          bellAsset: "assets/noti2.png",
                          iconAsset: "assets/SpO2.png",
                          value: "${_measurement!.oxygenLevel}%",
                          unit: "",
                          label: "SpO₂",
                          dark: false,
                        ),
                        _vitalCard(
                          bellAsset: "assets/noti1.png",
                          iconAsset: "assets/temp2.png",
                          value: _measurement!.temperature.toStringAsFixed(1),
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
                        ..._buildAlerts(),
                      ],
                    ),
    ),
  );

  }
}
