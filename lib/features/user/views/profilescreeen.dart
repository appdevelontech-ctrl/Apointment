import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_profile_controller.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String userId;
  const ProfileDetailsScreen({super.key, required this.userId});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final Color teal = const Color(0xFF137C76);

  final phoneCtrl = TextEditingController();
  final aboutCtrl = TextEditingController();
  final companyCtrl = TextEditingController();

  String profileImg = "";

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final c = Provider.of<UserProfileController>(context, listen: false);
      await c.loadUserProfile(widget.userId);

      final u = c.user;
      if (u != null) {
        phoneCtrl.text = u.phone;
        aboutCtrl.text = u.about;
        companyCtrl.text = u.company;
        profileImg = u.profile;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Provider.of<UserProfileController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),

      appBar: AppBar(
        backgroundColor: teal,
        elevation: 0,
        title: const Text("My Profile",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: c.isLoading ? null : () => _updateProfile(c),
            style: ElevatedButton.styleFrom(
              backgroundColor: teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: c.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "Save Changes",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),

      body: c.isLoading && c.user == null
          ? const Center(child: CircularProgressIndicator())
          : _body(),
    );
  }

  // ================= BODY =================
  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: teal,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImg.isEmpty
                      ? const NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/1077/1077012.png")
                      : NetworkImage(
                      "https://hospitalquee.onrender.com/$profileImg"),
                ),
                const SizedBox(height: 12),
                Text(
                  "Tap to change photo",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // ================= DETAILS CARD =================
          Container(
            margin: const EdgeInsets.all(18),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title("Phone Number"),
                _box(phoneCtrl, keyboard: TextInputType.phone),

                _title("About"),
                _box(aboutCtrl, maxLines: 4),

                _title("Company / Organization"),
                _box(companyCtrl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UPDATE =================
  Future<void> _updateProfile(UserProfileController c) async {
    final body = {
      "phone": phoneCtrl.text.trim(),
      "about": aboutCtrl.text.trim(),
      "company": companyCtrl.text.trim(),
    };

    final ok = await c.updateUserProfile(widget.userId, body);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Updated Successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Update Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= UI HELPERS =================
  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  Widget _box(
      TextEditingController ctrl, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: teal.withOpacity(0.28)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter here",
        ),
      ),
    );
  }
}
