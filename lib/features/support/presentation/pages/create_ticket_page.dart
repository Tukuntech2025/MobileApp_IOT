import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/services/support_service.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final SupportService _supportService = SupportService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supportService.createTicket(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket created successfully!')),
        );
        Navigator.pop(context, true); // Volver y recargar
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B1B),
        elevation: 0,
        title: Text(
          "Create Support Ticket",
          style: GoogleFonts.darkerGrotesque(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF0E8D5),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF0E8D5)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tell us about your issue",
                  style: GoogleFonts.josefinSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB0B0B0),
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                _buildTextField(
                  label: "Name",
                  controller: _nameController,
                  icon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 3) return 'Name too short';
                    return null;
                  },
                ),

                // Email
                _buildTextField(
                  label: "Email",
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),

                // Subject
                _buildTextField(
                  label: "Subject",
                  controller: _subjectController,
                  icon: Icons.subject,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 5) return 'Subject too short';
                    return null;
                  },
                ),

                // Description
                _buildTextField(
                  label: "Description",
                  controller: _descriptionController,
                  icon: Icons.description_outlined,
                  maxLines: 6,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 10) return 'Description too short';
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0E8D5),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            "Submit Ticket",
                            style: GoogleFonts.josefinSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.darkerGrotesque(
          fontSize: 16,
          color: const Color(0xFFF0E8D5),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.josefinSans(
            fontSize: 16,
            color: const Color(0xFFB0B0B0),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFFD1AA10)),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1AA10), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}