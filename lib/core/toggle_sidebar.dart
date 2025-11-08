import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/services/auth_service.dart';

class ToggleSidebar extends StatelessWidget {
  const ToggleSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: const Color(0xFF242424),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: Image.asset(
        "assets/sidebar.png",
        width: 28,
        height: 28,
        color: const Color(0xFFF0E8D5),
      ),
      onSelected: (value) async {
        switch (value) {
          case 0: // Subscription
            Navigator.of(context).pushNamed('/subscription');
            break;
          case 1: // Support
            Navigator.of(context).pushNamed('/support');
            break;
          case 2: // Log out
            await _logout(context);
            break;
        }
      },
      itemBuilder: (context) => [
        _buildMenuItem("assets/subscription.png", "Subscription", 0),
        _buildMenuItem("assets/support.png", "Support", 1),
        _buildMenuItem("assets/logout.png", "Log out", 2),
      ],
    );
  }

 
  Future<void> _logout(BuildContext context) async {
    final AuthService authService = AuthService();
    
    print(' Logging out...');
    
    
    await authService.removeToken();
    
    print(' Logged out successfully');
    
    
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  PopupMenuItem<int> _buildMenuItem(String iconPath, String text, int value) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 22,
            height: 22,
            color: const Color(0xFFF0E8D5),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.josefinSans(
              fontSize: 16,
              color: const Color(0xFFF0E8D5),
            ),
          ),
        ],
      ),
    );
  }
}