// splash_screen.dart
import 'package:flutter/material.dart';
import '../shared/utils/preferences.dart';
import '../features/doctor/views/doctor_dashboard.dart';
import '../features/hospital/views/hospital_dashboard.dart';
import 'features/doctor/controllers/doctor_auth_controller.dart';
import 'features/hospital/controllers/hospital_auth_controller.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    final userId = await PrefUtils.getUserId();
    final userType = await PrefUtils.getUserType();

    if (!mounted) return;

    if (userId != null && userType != null) {
      if (userType == "patient") {
        Navigator.pushReplacementNamed(context, '/user_dashboard');
      } else if (userType == "doctor") {
        final doctor = await DoctorAuthController().getCurrentDoctor();
        if (doctor != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DoctorDashboard(doctor: doctor)),
          );
        }
      } else if (userType == "hospital") {
        final hospital = await HospitalAuthController().getCurrentHospital();
        if (hospital != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HospitalDashboard(hospital: hospital)),
          );
        }
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF00695C), Color(0xFF004D40)]),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_hospital, size: 120, color: Colors.white),
              SizedBox(height: 30),
              Text("MediConnect Pro", style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 80),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}