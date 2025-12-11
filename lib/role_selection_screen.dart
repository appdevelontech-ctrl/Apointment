// role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF00695C), Color(0xFF004D40)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_hospital, size: 120, color: Colors.white),
                const SizedBox(height: 40),
                Text("Welcome to MediConnect", style: GoogleFonts.poppins(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Text("Continue as", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 50),

                _roleButton(context, "Patient", Icons.person, Colors.teal, '/user_login'),
                const SizedBox(height: 20),
                _roleButton(context, "Doctor", Icons.medical_services, Colors.indigo, '/doctor_login'),
                const SizedBox(height: 20),
                _roleButton(context, "Hospital", Icons.apartment, Colors.purple, '/hospital_login'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context, String title, IconData icon, Color color, String route) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(width: 16),
            Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}