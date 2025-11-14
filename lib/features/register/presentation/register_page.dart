import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Variable para el rol seleccionado
  String _selectedRole = 'PATIENT'; // Por defecto PATIENT

  // Función de registro
  Future<void> registerUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await _authService.registerUser(email, password, _selectedRole);

      // Redirigir al login después de registrar el usuario
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${error.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const beige = Color(0xFFF0E8D5);
    const primaryDark = Color(0xFF1B1B1B);

    return Scaffold(
      backgroundColor: beige,
      body: SafeArea(
        child: Stack(
          children: [
            // Botón de regreso/Login en la esquina superior izquierda
            Positioned(
              left: 12, // Cambiado de 'right' a 'left'
              top: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(), // Pop es suficiente para volver a la ruta anterior, si RegisterPage fue pusheada desde LoginPage
                child: Text(
                  // Usamos un icono o texto más claro para indicar regreso
                  '< LOGIN', 
                  style: GoogleFonts.josefinSans(
                    color: primaryDark,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            
            // Texto estático REGISTER en la esquina superior derecha
            Positioned(
              right: 12,
              top: 8,
              child: Text(
                'REGISTER',
                style: GoogleFonts.josefinSans(
                  color: primaryDark,
                  fontSize: 12,
                  letterSpacing: 1.2,
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
                        'WELCOME',
                        style: GoogleFonts.josefinSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Please complete all fields',
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Email
                      _DarkFieldBox(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 12),
                      
                      // Campo Password
                      _DarkFieldBox(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 16),

                      // 🆕 Selector de Rol
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, color: Colors.white70),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedRole,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF3A3A3A),
                                  style: GoogleFonts.darkerGrotesque(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'PATIENT',
                                      child: Text('Patient'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ATTENDANT',
                                      child: Text('Attendant'),
                                    ),
                                  ],
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedRole = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón Create
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: Text(
                            'Create',
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
}

class _DarkFieldBox extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextEditingController controller;

  const _DarkFieldBox({
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