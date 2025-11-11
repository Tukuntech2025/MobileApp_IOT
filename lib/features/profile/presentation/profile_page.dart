import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/core/base_screen.dart';
import 'package:tukuntech/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getMyProfile();
      print('🟢 Profile loaded: $profile');

      if (mounted) {
        setState(() {
          _profileData = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔴 Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileType = _profileData?['profileType']?.toString() ?? 'PATIENT';

    return BaseScreen(
      currentIndex: 3,
      title: profileType == 'PATIENT' ? 'Patient' : 'Attendant',
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF0E8D5)),
            )
          : _profileData == null
              ? Center(
                  child: Text(
                    'No profile found',
                    style: GoogleFonts.josefinSans(
                      fontSize: 18,
                      color: const Color(0xFFF0E8D5),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User Data",
                        style: GoogleFonts.josefinSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF0E8D5),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 2,
                        width: 120,
                        color: const Color(0xFFD1AA10),
                      ),
                      const SizedBox(height: 10),
                      _buildUserRow(
                        "Name",
                        _profileData?['firstName']?.toString() ?? 'N/A',
                      ),
                      _divider(),
                      _buildUserRow(
                        "Last Name",
                        _profileData?['lastName']?.toString() ?? 'N/A',
                      ),
                      _divider(),
                      _buildUserRow(
                        "DNI",
                        _profileData?['dni']?.toString() ?? 'N/A',
                      ),
                      _divider(),
                      _buildUserRow(
                        "Age",
                        _profileData?['age']?.toString() ?? 'N/A',
                      ),
                      _divider(),
                      _buildUserRow(
                        "Gender",
                        _formatValue(_profileData?['gender']?.toString()),
                      ),
                      _divider(),

                      // Solo mostrar campos clínicos si es PATIENT
                      if (profileType == 'PATIENT') ...[
                        _buildUserRow(
                          "Blood Group",
                          _formatValue(
                              _profileData?['bloodGroup']?.toString()),
                        ),
                        _divider(),
                        _buildUserRow(
                          "Nationality",
                          _formatValue(
                              _profileData?['nationality']?.toString()),
                        ),
                        _divider(),
                        _buildUserRow(
                          "Allergies",
                          _formatValue(
                              _profileData?['allergy']?.toString()),
                        ),
                      ],

                      const Spacer(),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_profileData == null) return;

                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  profileData: _profileData!,
                                ),
                              ),
                            );

                            // Si se actualizó, recargar
                            if (result == true) {
                              print('🟡 Profile updated, reloading data...');
                              _loadProfile();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0E8D5),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Update",
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
    );
  }

  Widget _buildUserRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: GoogleFonts.darkerGrotesque(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF0E8D5),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.darkerGrotesque(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF0E8D5),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      color: Color(0xFF555555),
      thickness: 1,
      height: 16,
    );
  }

  String _formatValue(String? value) {
    if (value == null || value.isEmpty) return 'N/A';
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}


class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfilePage({super.key, required this.profileData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dniController;
  late TextEditingController _ageController;

  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedNationality;
  String? _selectedAllergy;

  bool _isLoading = false;
  bool _isPatient = false;

  @override
  void initState() {
    super.initState();
    _isPatient = widget.profileData['profileType'] == 'PATIENT';

    _firstNameController = TextEditingController(
      text: widget.profileData['firstName']?.toString() ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.profileData['lastName']?.toString() ?? '',
    );
    _dniController = TextEditingController(
      text: widget.profileData['dni']?.toString() ?? '',
    );
    _ageController = TextEditingController(
      text: widget.profileData['age']?.toString() ?? '',
    );

    _selectedGender = widget.profileData['gender']?.toString();
    _selectedBloodGroup = widget.profileData['bloodGroup']?.toString();
    _selectedNationality = widget.profileData['nationality']?.toString();
    _selectedAllergy = widget.profileData['allergy']?.toString();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _profileService.updateMyProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dni: _dniController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        bloodGroup: _isPatient ? _selectedBloodGroup : null,
        nationality: _isPatient ? _selectedNationality : null,
        allergy: _isPatient ? _selectedAllergy : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
          ),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      print('🔴 Error updating profile: $e');
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
          "Edit Profile",
          style: GoogleFonts.darkerGrotesque(
            fontSize: 28,
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
              children: [
                _buildTextField(
                  "First Name",
                  _firstNameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                _buildTextField(
                  "Last Name",
                  _lastNameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                _buildTextField(
                  "DNI",
                  _dniController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length != 8) return 'DNI must be 8 digits';
                    return null;
                  },
                ),
                _buildTextField(
                  "Age",
                  _ageController,
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
                _buildDropdown(
                  "Gender",
                  _selectedGender,
                  ['MALE', 'FEMALE', 'OTHER'],
                  (v) => setState(() => _selectedGender = v),
                ),

                // Solo mostrar campos clínicos si es paciente
                if (_isPatient) ...[
                  _buildDropdown(
                    "Blood Group",
                    _selectedBloodGroup,
                    [
                      'O_POSITIVE',
                      'O_NEGATIVE',
                      'A_POSITIVE',
                      'A_NEGATIVE',
                      'B_POSITIVE',
                      'B_NEGATIVE',
                      'AB_POSITIVE',
                      'AB_NEGATIVE'
                    ],
                    (v) => setState(() => _selectedBloodGroup = v),
                  ),
                  _buildDropdown(
                    "Nationality",
                    _selectedNationality,
                    [
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
                    (v) => setState(() => _selectedNationality = v),
                  ),
                  _buildDropdown(
                    "Allergy",
                    _selectedAllergy,
                    [
                      'PENICILLIN',
                      'ASPIRIN',
                      'LACTOSE',
                      'PEANUTS',
                      'SEAFOOD',
                      'GLUTEN',
                      'NONE',
                      'OTHER'
                    ],
                    (v) => setState(() => _selectedAllergy = v),
                  ),
                ],

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
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
                            "Save",
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
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

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value.isNotEmptyOrNull && items.contains(value)
            ? value
            : null,
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

  String _formatEnumValue(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word[0].toUpperCase() + word.substring(1).toLowerCase())
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

extension _StringNullCheck on String? {
  bool get isNotEmptyOrNull => this != null && this!.isNotEmpty;
}
