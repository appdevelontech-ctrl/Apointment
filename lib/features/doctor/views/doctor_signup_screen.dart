// features/doctor/views/doctor_signup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/services/api_service.dart';
import 'doctor_login_screen.dart';

const Color kTeal = Color(0xFF00695C);

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});
  @override
  State<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _loadingZones = true;
  bool _loadingDepts = true;

  List<Map<String, dynamic>> states = [];
  List<String> cities = [];
  List<Map<String, dynamic>> departments = [];
  List<String> selectedDeptIds = [];

  String? selectedStateId;
  String? selectedCity;

  File? _profileImage;
  File? _doc1, _doc2, _doc3;

  final Map<String, dynamic> _formData = {
    "username": "",
    "phone": "",
    "email": "",
    "password": "",
    "confirm_password": "",
    "pincode": "",
    "Gender": "1",
    "DOB": "",
    "address": "",
    "department": [],
    "state": "",
    "statename": "",
    "city": "",
    "type": "1",
    "headId": "691d6ad39a5aea16a748c4f2",
    "empType": "3"
  };

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([ApiService.getAllZones(), ApiService.getAllDepartments()]);
      if (!mounted) return;

      setState(() {
        states = (results[0] as List).cast<Map<String, dynamic>>();
        departments = (results[1] as List).cast<Map<String, dynamic>>();
        _loadingZones = false;
        _loadingDepts = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingZones = _loadingDepts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load data. Please try again.")),
        );
      }
    }
  }

  void _onStateChanged(String? stateId) {
    if (stateId == null) return;
    final state = states.firstWhere((s) => s['_id'] == stateId, orElse: () => <String, dynamic>{});
    if (state.isEmpty) return;

    setState(() {
      selectedStateId = stateId;
      cities = List<String>.from(state['cities'] ?? []);
      selectedCity = null;
      _formData["state"] = stateId;
      _formData["statename"] = state['name'] ?? '';
      _formData["city"] = "";
    });
  }

  String _normalizeDob(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return "";
    // Accepts YYYY-MM-DD (ok), DD-MM-YYYY (convert), or other simple separators
    final parts = s.split(RegExp(r'[-\/\.]'));
    if (parts.length != 3) return s; // unknown format — send as is
    // if already yyyy-mm-dd
    if (parts[0].length == 4) {
      return s; // assume correct
    }
    // else assume dd-mm-yyyy or mm-dd-yyyy; we'll treat as dd-mm-yyyy (user UI says DD/MM/YYYY possible)
    final dd = parts[0].padLeft(2, '0');
    final mm = parts[1].padLeft(2, '0');
    final yyyy = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
    return "$yyyy-$mm-$dd";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final horizontalPadding = isTablet ? size.width * 0.15 : 24.0;
    final avatarRadius = isTablet ? 80.0 : 60.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Doctor Registration", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTeal, fontSize: isTablet ? 26 : 22)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Photo
                        Center(
                          child: GestureDetector(
                            onTap: () => _pickImage("profile"),
                            child: CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: kTeal.withOpacity(0.15),
                              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                              child: _profileImage == null
                                  ? Icon(Icons.camera_alt, size: avatarRadius * 0.7, color: kTeal)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            "Tap to add profile photo",
                            style: GoogleFonts.poppins(color: kTeal, fontSize: isTablet ? 18 : 15),
                          ),
                        ),
                        SizedBox(height: isTablet ? 40 : 30),

                        // Form Fields Grid for Tablet
                        if (isTablet)
                          _buildTabletGrid()
                        else
                          _buildMobileForm(),

                        const SizedBox(height: 40),

                        // Submit Button
                        SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kTeal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 10,
                              shadowColor: kTeal.withOpacity(0.4),
                            ),
                            onPressed: _isLoading ? null : _signup,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              "CREATE DOCTOR ACCOUNT",
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorLoginScreen())),
                            child: RichText(
                              text: TextSpan(
                                text: "Already registered? ",
                                style: const TextStyle(color: Colors.black87),
                                children: [
                                  TextSpan(
                                    text: "Login now",
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTeal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileForm() {
    return Column(
      children: [
        _buildTextField("Full Name (Dr. Name)", Icons.person, (v) => _formData["username"] = v!),
        _buildTextField("Phone", Icons.phone, (v) => _formData["phone"] = v!, keyboardType: TextInputType.phone),
        _buildTextField("Email", Icons.email, (v) => _formData["email"] = v!, keyboardType: TextInputType.emailAddress),
        _buildTextField("Password", Icons.lock, (v) => _formData["password"] = v!, obscureText: true),
        _buildTextField("Confirm Password", Icons.lock_outline, (v) => _formData["confirm_password"] = v!, obscureText: true),

        Row(
          children: [
            Expanded(child: _buildTextField("Pincode", Icons.pin_drop, (v) => _formData["pincode"] = v!, keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("DOB (YYYY-MM-DD)", Icons.calendar_today, (v) => _formData["DOB"] = v!)),
          ],
        ),

        _buildTextField("Clinic/Hospital Address", Icons.home, (v) => _formData["address"] = v!, maxLines: 2),

        const SizedBox(height: 20),
        _buildStateCityDropdowns(),
        const SizedBox(height: 24),

        Text("Select Specializations", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: kTeal)),
        const SizedBox(height: 12),
        _buildDepartmentsChips(),

        const SizedBox(height: 30),
        Text("Upload Documents (Optional)", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: kTeal)),
        const SizedBox(height: 12),
        _buildFileTile("Medical Registration", _doc1, () => _pickImage("doc1")),
        _buildFileTile("Degree Certificate", _doc2, () => _pickImage("doc2")),
        _buildFileTile("ID Proof", _doc3, () => _pickImage("doc3")),
      ],
    );
  }

  Widget _buildTabletGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField("Full Name", Icons.person, (v) => _formData["username"] = v!)),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField("Phone", Icons.phone, (v) => _formData["phone"] = v!, keyboardType: TextInputType.phone)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField("Email", Icons.email, (v) => _formData["email"] = v!, keyboardType: TextInputType.emailAddress)),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField("Password", Icons.lock, (v) => _formData["password"] = v!, obscureText: true)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField("Pincode", Icons.pin_drop, (v) => _formData["pincode"] = v!, keyboardType: TextInputType.number)),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField("DOB", Icons.calendar_today, (v) => _formData["DOB"] = v!)),
          ],
        ),
        _buildTextField("Address", Icons.home, (v) => _formData["address"] = v!, maxLines: 2),
        const SizedBox(height: 20),
        _buildStateCityDropdowns(isTablet: true),
        const SizedBox(height: 20),
        _buildDepartmentsChips(isTablet: true),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(child: _buildFileTile("Medical Reg.", _doc1, () => _pickImage("doc1"))),
            const SizedBox(width: 20),
            Expanded(child: _buildFileTile("Degree Cert.", _doc2, () => _pickImage("doc2"))),
            const SizedBox(width: 20),
            Expanded(child: _buildFileTile("ID Proof", _doc3, () => _pickImage("doc3"))),
          ],
        ),
      ],
    );
  }

  Widget _buildStateCityDropdowns({bool isTablet = false}) {
    // Agar tablet hai toh side-by-side layout, warna vertical
    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: _loadingZones
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
              value: selectedStateId,
              decoration: _inputDecoration("Select State"),
              hint: const Text("Choose state"),
              items: states.map((s) => DropdownMenuItem(
                value: s['_id'] as String,
                child: Text(s['name'] as String),
              )).toList(),
              onChanged: _onStateChanged,
              validator: (v) => v == null ? "State required" : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: selectedStateId == null
                ? Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Select state first",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ),
            )
                : DropdownButtonFormField<String>(
              value: selectedCity,
              decoration: _inputDecoration("Select City"),
              hint: const Text("Choose city"),
              items: cities.map((c) => DropdownMenuItem(value: c, child:Text(c))).toList(),
              onChanged: (v) {
                setState(() => selectedCity = v);
                _formData["city"] = v;
              },
              validator: (v) => v == null ? "City required" : null,
            ),
          ),
        ],
      );
    }

    // Mobile View - Vertical Layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _loadingZones
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator()),
        )
            : DropdownButtonFormField<String>(
          value: selectedStateId,
          decoration: _inputDecoration("Select State"),
          hint: const Text("Choose your state"),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTeal),
          items: states.map((s) {
            return DropdownMenuItem<String>(
              value: s['_id'] as String,
              child: Text(s['name'] as String),
            );
          }).toList(),
          onChanged: _onStateChanged,
          validator: (v) => v == null ? "Please select state" : null,
        ),

        const SizedBox(height: 18),

        // City Field
        if (selectedStateId == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                const Text("First select a state to see cities"),
              ],
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: selectedCity,
            decoration: _inputDecoration("Select City"),
            hint: const Text("Choose your city"),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTeal),
            items: cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedCity = value);
              _formData["city"] = value;
            },
            validator: (v) => v == null ? "Please select city" : null,
          ),
      ],
    );
  }

  Widget _buildDepartmentsChips({bool isTablet = false}) {
    return _loadingDepts
        ? const Center(child: CircularProgressIndicator())
        : Wrap(
      spacing: isTablet ? 16 : 10,
      runSpacing: 12,
      children: departments.map((dept) {
        final id = dept['_id'] as String;
        final name = dept['name'] as String;
        final selected = selectedDeptIds.contains(id);
        return FilterChip(
          label: Text(name, style: TextStyle(fontSize: isTablet ? 16 : 14)),
          selected: selected,
          selectedColor: kTeal,
          checkmarkColor: Colors.white,
          onSelected: (sel) {
            setState(() {
              // prevent duplicates
              if (sel) {
                if (!selectedDeptIds.contains(id)) selectedDeptIds.add(id);
              } else {
                selectedDeptIds.remove(id);
              }
              _formData["department"] = selectedDeptIds;
            });
          },
        );
      }).toList(),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kTeal, width: 2)),
  );

  Widget _buildTextField(String label, IconData icon, FormFieldSetter<String> onSaved,
      {TextInputType? keyboardType, bool obscureText = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label).copyWith(prefixIcon: Icon(icon, color: kTeal)),
        validator: (v) => v!.trim().isEmpty ? "Required" : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildFileTile(String label, File? file, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: kTeal.withOpacity(0.1), child: Icon(file != null ? Icons.check : Icons.upload, color: kTeal)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: file != null ? Text(file.path.split('/').last, overflow: TextOverflow.ellipsis) : const Text("Tap to upload"),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() {
        final file = File(picked.path);
        if (type == "profile") _profileImage = file;
        if (type == "doc1") _doc1 = file;
        if (type == "doc2") _doc2 = file;
        if (type == "doc3") _doc3 = file;
      });
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate() || selectedStateId == null || selectedCity == null || selectedDeptIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    if (_formData["password"] != _formData["confirm_password"]) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }

    _formKey.currentState!.save();

    // normalize DOB
    _formData["DOB"] = _normalizeDob((_formData["DOB"] ?? "").toString());

    // make sure state and city values are set
    if (selectedStateId != null) _formData["state"] = selectedStateId;
    if (selectedCity != null) _formData["city"] = selectedCity;

    // debug
    debugPrint("Submitting departments: ${_formData["department"]}");

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.doctorSignupWithFiles(
        data: _formData,
        profile: _profileImage,
        doc1: _doc1,
        doc2: _doc2,
        doc3: _doc3,
      );

      if (!mounted) return;

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Success!"), backgroundColor: Colors.green));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorLoginScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response["message"] ?? "Failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
