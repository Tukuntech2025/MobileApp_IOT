import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/services/profile_service.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _ageController = TextEditingController();

  // Dropdowns
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedNationality;
  String? _selectedAllergy;

  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _profileService.createProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dni: _dniController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        nationality: _selectedNationality,
        allergy: _selectedAllergy,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile created successfully!')),
        );
        // Redirigir al home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Complete Profile",
              style: GoogleFonts.darkerGrotesque(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF0E8D5),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 180,
              color: const Color(0xFFF0E8D5),
            ),
          ],
        ),
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
                  "Please complete your profile to continue",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 16,
                    color: const Color(0xFFB0B0B0),
                  ),
                ),
                const SizedBox(height: 24),

                // First Name
                _buildTextField(
                  label: "First Name",
                  controller: _firstNameController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),

                // Last Name
                _buildTextField(
                  label: "Last Name",
                  controller: _lastNameController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),

                // DNI
                _buildTextField(
                  label: "DNI",
                  controller: _dniController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length != 8) return 'DNI must be 8 digits';
                    return null;
                  },
                ),

                // Age
                _buildTextField(
                  label: "Age",
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    int? age = int.tryParse(v);
                    if (age == null || age < 0 || age > 120) {
                      return 'Invalid age';
                    }
                    return null;
                  },
                ),

                // Gender
                _buildDropdown(
                  label: "Gender",
                  value: _selectedGender,
                  items: const ['MALE', 'FEMALE', 'OTHER'],
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),

                // Blood Group
                _buildDropdown(
                  label: "Blood Group",
                  value: _selectedBloodGroup,
                  items: const [
                    'O_POSITIVE',
                    'O_NEGATIVE',
                    'A_POSITIVE',
                    'A_NEGATIVE',
                    'B_POSITIVE',
                    'B_NEGATIVE',
                    'AB_POSITIVE',
                    'AB_NEGATIVE'
                  ],
                  onChanged: (v) => setState(() => _selectedBloodGroup = v),
                ),

                // Nationality
                _buildDropdown(
                  label: "Nationality",
                  value: _selectedNationality,
                  items: const [
                    'PERUVIAN',
                    'COLOMBIAN',
                    'MEXICAN',
                    'CHILEAN',
                    'ARGENTINIAN',
                    'VENEZUELAN',
                    'ECUADORIAN',
                    'BOLIVIAN',
                    'OTHER'
                  ],
                  onChanged: (v) => setState(() => _selectedNationality = v),
                ),

                // Allergy
                _buildDropdown(
                  label: "Allergy",
                  value: _selectedAllergy,
                  items: const [
                    'PENICILLIN',
                    'ASPIRIN',
                    'LACTOSE',
                    'PEANUTS',
                    'SEAFOOD',
                    'GLUTEN',
                    'NONE',
                    'OTHER'
                  ],
                  onChanged: (v) => setState(() => _selectedAllergy = v),
                ),

                const SizedBox(height: 30),

                // Botón Save
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
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
                            "Save Profile",
                            style: GoogleFonts.josefinSans(
                              fontSize: 20,
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.darkerGrotesque(
          fontSize: 18,
          color: const Color(0xFFF0E8D5),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.josefinSans(
            fontSize: 16,
            color: const Color(0xFFF0E8D5),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF0E8D5)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD1AA10), width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.josefinSans(
            fontSize: 16,
            color: const Color(0xFFF0E8D5),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF0E8D5)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD1AA10), width: 2),
          ),
        ),
        dropdownColor: const Color(0xFF3A3A3A),
        style: GoogleFonts.darkerGrotesque(
          fontSize: 18,
          color: const Color(0xFFF0E8D5),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              _formatEnumValue(item),
              style: GoogleFonts.darkerGrotesque(
                fontSize: 18,
                color: const Color(0xFFF0E8D5),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Formatear valores enum para mostrar bonito
  String _formatEnumValue(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dniController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}