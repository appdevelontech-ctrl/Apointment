// features/doctor/views/doctor_login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/glass_container.dart';
import '../controllers/doctor_auth_controller.dart';
import 'doctor_dashboard.dart';
import 'doctor_signup_screen.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({Key? key}) : super(key: key);

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _email = TextEditingController(text: "doctor2@gmail.com");
  final _pass = TextEditingController(text: "9871");
  final _controller = DoctorAuthController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);

    _controller.login(_email.text.trim(), _pass.text).then((doctor) {
      if (doctor != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => DoctorDashboard(doctor: doctor)),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Doctor Credentials or Not a Doctor"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }).whenComplete(() {
      if (mounted) setState(() => _loading = false);
    });
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
      resizeToAvoidBottomInset: true, // Important
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00695C),
                  Color(0xFF004D40),
                ],
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
                      // Logo & Title
                      const SizedBox(height: 20),
                      Icon(Icons.local_hospital_outlined,
                          size: constraints.maxWidth > 450 ? 140 : 100,
                          color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        "Doctor Login",
                        style: GoogleFonts.poppins(
                          fontSize: constraints.maxWidth > 450 ? 40 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Responsive Glass Card
                      GlassContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(28),
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
                                prefixIcon:
                                Icon(Icons.email, color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white38),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.cyanAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Password
                            TextField(
                              controller: _pass,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.white70),
                                prefixIcon:
                                Icon(Icons.lock, color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white38),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.cyanAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 35),

                            // NEW DOCTOR BUTTON
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const DoctorSignupScreen())),
                              child: const Text(
                                "New Doctor? Create Account",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // LOGIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 7,
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : Text(
                                  "LOGIN AS DOCTOR",
                                  style: GoogleFonts.poppins(
                                    fontSize: constraints.maxWidth > 450
                                        ? 20
                                        : 17,
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
