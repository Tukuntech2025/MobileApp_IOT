import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/services/auth_service.dart';
import 'package:tukuntech/services/profile_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;

  // 🆕 Función de login mejorada
  Future<void> loginUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Login
      await _authService.loginUser(email, password);
      print('🟢 Login successful');

      // 2. Verificar si tiene perfil creado
      final hasProfile = await _profileService.hasProfile();
      print('🔵 Has profile: $hasProfile');

      if (mounted) {
        if (hasProfile) {
          // Ya tiene perfil -> ir al home
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        } else {
          // No tiene perfil -> ir a completar perfil
          Navigator.of(context).pushNamedAndRemoveUntil('/complete-profile', (route) => false);
        }
      }
    } catch (error) {
      print('🔴 Login error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${error.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const beige = Color(0xFFF0E8D5);

    return Scaffold(
      backgroundColor: beige,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 12,
              top: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/register'),
                child: Text(
                  'REGISTER',
                  style: GoogleFonts.josefinSans(
                    color: const Color(0xFF1B1B1B),
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // Contenido
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/icon.png', height: 56),
                      const SizedBox(height: 6),
                      Text(
                        'TUKUNTECH',
                        style: GoogleFonts.josefinSans(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'WELCOME BACK',
                        style: GoogleFonts.josefinSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Login to your account',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DarkFieldBox(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 12),
                      _DarkFieldBox(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.josefinSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _DarkFieldBox extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextEditingController controller;

  const _DarkFieldBox({
    super.key,
    required this.hint,
    this.icon,
    this.obscure = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const field = Color(0xFF3A3A3A);

    return Container(
      decoration: BoxDecoration(
        color: field,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.darkerGrotesque(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          icon: icon != null ? Icon(icon, color: Colors.white70) : null,
          hintText: hint,
          hintStyle: GoogleFonts.darkerGrotesque(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}