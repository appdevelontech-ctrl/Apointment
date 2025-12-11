// main.dart
import 'package:appointment_app/features/user/controllers/home_controller.dart';
import 'package:appointment_app/features/user/controllers/user_profile_controller.dart';
import 'package:appointment_app/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/doctor/views/doctor_login_screen.dart';
import 'features/hospital/views/hospital_login_screen.dart';
import 'features/user/controllers/home_header_controller.dart';
import 'features/user/providers/navigation_provider.dart';
import 'features/user/views/dashboard_screen.dart';
import 'features/user/views/auth/loginscreen.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';



void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_)=>HomeController()),
        ChangeNotifierProvider(create: (_)=>UserProfileController()),
        ChangeNotifierProvider(create: (_) => HomeHeaderController()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediConnect Pro',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(),
      routes: {
        '/role_selection': (_) => const RoleSelectionScreen(),
        '/user_login': (_) => const PatientLoginScreen(),
        '/doctor_login': (_) => const DoctorLoginScreen(),
        '/hospital_login': (_) => const HospitalLoginScreen(),
        '/user_dashboard': (_) => const UserDashboardScreen(),
      },
    );
  }
}