// features/hospital/views/hospital_login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/glass_container.dart';
import '../controllers/hospital_auth_controller.dart';
import 'hospital_dashboard.dart';

class HospitalLoginScreen extends StatefulWidget {
  const HospitalLoginScreen({Key? key}) : super(key: key);

  @override
  State<HospitalLoginScreen> createState() => _HospitalLoginScreenState();
}

class _HospitalLoginScreenState extends State<HospitalLoginScreen> {
  final _email = TextEditingController(text: "gangaram@gmail.com");
  final _pass = TextEditingController(text: "9871");
  late final _controller = HospitalAuthController();

  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);

    final hospital = await _controller.login(_email.text.trim(), _pass.text);

    setState(() => _loading = false);

    if (hospital != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HospitalDashboard(hospital: hospital)),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Hospital Credentials"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF0D1133)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight * 0.9,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      const SizedBox(height: 20),
                      Icon(
                        Icons.apartment,
                        size: constraints.maxWidth > 450 ? 140 : 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        "Hospital Login",
                        style: GoogleFonts.poppins(
                          fontSize: constraints.maxWidth > 450 ? 38 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Glass Login Card (Responsive)
                      GlassContainer(
                        borderRadius: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                        child: Column(
                          children: [
                            // Email
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: Colors.white70),
                                prefixIcon: Icon(Icons.email, color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white38),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.cyanAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Password
                            TextField(
                              controller: _pass,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.white70),
                                prefixIcon: Icon(Icons.lock, color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white38),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.cyanAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // LOGIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigoAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 10,
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  "LOGIN AS HOSPITAL",
                                  style: GoogleFonts.poppins(
                                    fontSize: constraints.maxWidth > 450 ? 20 : 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
