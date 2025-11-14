import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/services/auth_service.dart';
import 'package:tukuntech/core/base_screen.dart';
import 'package:intl/intl.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userRole = 'Loading...';
  List<dynamic> _alerts = []; 
  bool _isLoadingAlerts = true; 
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _getUserRole();
    await _getAlerts();
  }

  Future<void> _getUserRole() async {
    try {
      List<String> roles = await _authService.getRoles();
      
      setState(() {
        if (roles.isEmpty) {
          _userRole = 'No role assigned';
        } else if (roles.contains('ADMINISTRATOR')) {
          _userRole = 'Administrator';
        } else if (roles.contains('ATTENDANT')) {
          _userRole = 'Attendant';
        } else if (roles.contains('PATIENT')) {
          _userRole = 'Patient';
        } else {
          _userRole = roles.join(', ');
        }
      });
      
      print('User role: $_userRole');
    } catch (e) {
      print('Error getting user role: $e');
      setState(() {
        _userRole = 'Error loading role';
      });
    }
  }

  String _formatTime(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp).toLocal();
      return DateFormat('hh:mm a').format(dateTime); 
    } catch (e) {
      print('Error formatting date: $e');
      return 'N/A';
    }
  }

  Future<void> _getAlerts() async {
    setState(() {
      _isLoadingAlerts = true;
    });

    try {
      const int patientId = 21; 
      final List<dynamic> fetchedAlerts =
          await _authService.getPatientAlerts(patientId);

      fetchedAlerts.sort((a, b) {
        final DateTime dateA = DateTime.parse(a['createdAt']);
        final DateTime dateB = DateTime.parse(b['createdAt']);
        return dateB.compareTo(dateA); 
      });

      final List<dynamic> limitedAlerts = fetchedAlerts.take(3).toList();

      setState(() {
        _alerts = limitedAlerts;
        _isLoadingAlerts = false;
      });
      
      print('🟢 Alerts fetched successfully: ${_alerts.length} alerts.');
    } catch (e) {
      print('🔴 Error getting alerts: $e');
      setState(() {
        _alerts = [
          {'message': 'Error loading alerts', 'createdAt': DateTime.now().toIso8601String()}
        ];
        _isLoadingAlerts = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 0,
      title: "Home", 
      child: Container(
        color: const Color(0xFF1B1B1B),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView( 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: const Color(0xFFF0E8D5),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Role',
                          style: GoogleFonts.josefinSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF0E8D5).withOpacity(0.7),
                          ),
                        ),
                        Text(
                          _userRole,
                          style: GoogleFonts.josefinSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF0E8D5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("LATEST ALERTS"),
                    const SizedBox(height: 6),
                    Text(
                      _isLoadingAlerts 
                          ? "Loading alerts..." 
                          : _alerts.isEmpty 
                              ? "No active alerts."
                              : "Here you can see the latest alerts (${_alerts.length})",
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 14,
                        color: const Color(0xFFF0E8D5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Mostrar un indicador de carga o la lista dinámica de alertas
                    _isLoadingAlerts
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD1AA10)))
                        : Column(
                            children: _alerts.map<Widget>((alert) {
                              final String fullMessage = alert['message'] ?? 'Unknown Alert';
                              final String message = fullMessage.replaceAll(' → ', '\n');
                              final String time = _formatTime(alert['createdAt']); 
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _alertBox(message, time),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("REMINDER"),
                    const SizedBox(height: 12),
                    Text(
                      "Take your medication on time and track your habits.",
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 14,
                        color: const Color(0xFFF0E8D5),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/subscription');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0E8D5),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Go to Subscription",
                          style: GoogleFonts.josefinSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.josefinSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF0E8D5),
          ),
        ),
        const Divider(thickness: 1, color: Color(0xFFF0E8D5)),
      ],
    );
  }

  Widget _alertBox(String text, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD1AA10), 
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.black,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.darkerGrotesque(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.darkerGrotesque(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}