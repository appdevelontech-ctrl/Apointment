import 'package:flutter/material.dart';
import '../services/user_api_service.dart';

class ProfileEditScreen extends StatefulWidget {

  final Map<String, dynamic> user;

  const ProfileEditScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final aboutCtrl = TextEditingController();

  bool loading = false;
  final Color teal = const Color(0xFF137C76);

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    nameCtrl.text = u["username"] ?? "";
    phoneCtrl.text = u["phone"] ?? "";
    emailCtrl.text = u["email"] ?? "";
    pincodeCtrl.text = u["pincode"] ?? "";
    cityCtrl.text = u["city"] ?? "";
    addressCtrl.text = u["address"] ?? "";
    aboutCtrl.text = u["about"] ?? "";
  }

  Future<void> _update() async {
    setState(() => loading = true);

    final body = {
      "type": "",
      "username": nameCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "email": emailCtrl.text.trim(),

      // 🔒 REQUIRED FIXES
      "SetEmail": null,
      "password": "",
      "confirm_password": "",

      "pincode": pincodeCtrl.text.trim(),
      "Gender": widget.user["Gender"] ?? "1",
      "DOB": "",
      "address": addressCtrl.text.trim(),

      // 🔒 FIXED STATE
      "state": "691475c786ca17d162f617d9",
      "statename": "Delhi",

      "country": "",
      "city": cityCtrl.text.trim(),
      "about": aboutCtrl.text.trim(),

      // PROFILE (future binary)
      "profile": null,
      "profile_url": widget.user["profile_url"] ?? "",
    };

    final ok = await UserApiService.updateUserDetails(
      widget.user["_id"].toString(),
      body,
    );

    if (!mounted) return;

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Profile Updated Successfully" : "Update Failed"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      appBar: AppBar(
        backgroundColor: teal,
        title: const Text("Edit Profile",
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _field("Full Name", nameCtrl),
            _field("Phone", phoneCtrl,
                keyboard: TextInputType.phone),
            _field("Email", emailCtrl,
                keyboard: TextInputType.emailAddress),
            _field("City", cityCtrl),
            _field("Pincode", pincodeCtrl,
                keyboard: TextInputType.number),
            _field("Address", addressCtrl, maxLines: 3),
            _field("About", aboutCtrl, maxLines: 4),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: loading ? null : _update,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Save Changes",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {int maxLines = 1,
        TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
