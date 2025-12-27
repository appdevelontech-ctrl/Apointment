import 'package:flutter/material.dart';
import '../services/user_api_service.dart';
import '../../../shared/utils/preferences.dart';
import 'profiledetailscreen.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final Color teal = const Color(0xFF137C76);

  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = await PrefUtils.getUserId();
      if (userId == null) return;

      final data = await UserApiService.getCurrentUser(userId);

      setState(() {
        user = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ PROFILE LOAD ERROR → $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load profile")),
      );
    }

    final img = (user!["profile_url"] != null &&
        user!["profile_url"].toString().isNotEmpty)
        ? user!["profile_url"]
        : "https://cdn-icons-png.flaticon.com/512/1077/1077012.png";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F6),
      appBar: AppBar(
        backgroundColor: teal,
        elevation: 0,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title:
        const Text("My Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.fromLTRB(150, 60, 150, 80),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF137C76), Color(0xFF1CA39A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(img),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user!["username"] ?? "User",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user!["phone"] ?? "",
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ================= INFO CARD =================
            Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
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
                children: [
                  _row("Email", user!["email"] ?? "-"),
                  _row("City", user!["city"] ?? "-"),
                  _row("State", user!["statename"] ?? "-"),
                  _row("Pincode", user!["pincode"] ?? "-"),
                  _row("About",
                      user!["about"]?.isNotEmpty == true
                          ? user!["about"]
                          : "Not added"),
                ],
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.fromLTRB(16, 6, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileEditScreen(user: user!),
                      ),
                    );

                    // 🔥 AFTER EDIT → REFRESH PROFILE
                    _loadProfile();
                  },
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String t, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(t,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600))),
          Expanded(
              flex: 5,
              child: Text(v,
                  style:
                  TextStyle(color: Colors.grey.shade700))),
        ],
      ),
    );
  }
}
