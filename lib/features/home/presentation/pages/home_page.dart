import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/services/auth_service.dart';
import 'package:tukuntech/core/base_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userRole = 'Loading...';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  // Obtener los roles desde SharedPreferences
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

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 0,
      title: "Home", 
      child: Container(
        color: const Color(0xFF1B1B1B),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar el rol del usuario
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
                    "Here you can see the latest alerts",
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 14,
                      color: const Color(0xFFF0E8D5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _alertBox("Low oxygenation", "10:30 AM"),
                  const SizedBox(height: 10),
                  _alertBox("Low oxygenation", "11:05 AM"),
                  const SizedBox(height: 10),
                  _alertBox("Low oxygenation", "12:40 PM"),
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