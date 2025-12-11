// features/doctor/views/doctor_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import '../../../shared/utils/preferences.dart';

class DoctorDashboard extends StatefulWidget {
  final Doctor doctor;
  const DoctorDashboard({required this.doctor});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {


  late Map<String, dynamic> doctorData;

  int todaysPatients = 0;
  int totalAppointmentsThisMonth = 0;
  double monthlyEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    loadDashboardData();    // NEW
  }

  void loadDashboardData() async {
    final rawData = await PrefUtils.getDoctorRawData();

    print('RawData is: $rawData');
    if (rawData != null) {
      processDoctorDashboardData(rawData);
    }
  }


// Call this function after successful login
  void processDoctorDashboardData(Map<String, dynamic> response) {
    doctorData = response['existingUser'];

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    todaysPatients = 0;
    totalAppointmentsThisMonth = 0;

    // Parse schedule and stats to calculate real values
    final schedule = doctorData['schedule'] as Map<String, dynamic>? ?? {};
    final stats = doctorData['stats'] as Map<String, dynamic>? ?? {};

    schedule.forEach((hospitalId, days) {
      days.forEach((dayName, dayData) {
        if (dayName == _getCurrentDayName()) {
          final slots = dayData['slots'] as List<dynamic>? ?? [];
          for (var slot in slots) {
            final patientsCount = int.tryParse(slot['patients'].toString()) ?? 0;
            todaysPatients += patientsCount;
          }
        }

        // Count total appointments in this month (you can enhance with actual booking data later)
        final slots = dayData['slots'] as List<dynamic>? ?? [];
        for (var slot in slots) {
          final patientsCount = int.tryParse(slot['patients'].toString()) ?? 0;
          totalAppointmentsThisMonth += patientsCount;
        }
      });
    });

    // Monthly Earnings Calculation (Example: ₹800 per patient)
    const double feePerPatient = 800.0;
    monthlyEarnings = totalAppointmentsThisMonth * feePerPatient;

    setState(() {}); // Refresh UI
  }

  String _getCurrentDayName() {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[DateTime.now().weekday % 7]; // Sunday = 0 in Mongo, but DateTime gives 7
  }
  // ------------------------- GREETING ---------------------------
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 20) return "Good Evening";
    return "Good Night";
  }

  // ------------------------- LOGOUT DIALOG -----------------------
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF00372E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Logout?",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        content: Text("Are you sure you want to logout?",
            style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            Text("Cancel", style: GoogleFonts.poppins(color: Colors.cyanAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              PrefUtils.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/doctor_login', (r) => false);
            },
            child: Text("Logout",
                style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // --------------------------- MAIN UI --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00251A),
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _confirmLogout(context),
              child: const Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --------------------------- HEADER ---------------------------
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 90),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF004D40)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),

              child: Row(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(widget.doctor.profile),
                  ),
                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getGreeting(),
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          widget.doctor.name,
                          style: GoogleFonts.poppins(
                            color: Colors.cyanAccent,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${widget.doctor.experience} years experience",
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          "${widget.doctor.city}, ${widget.doctor.state}",
                          style: GoogleFonts.poppins(
                              color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ------------------- DYNAMIC STAT CARDS -------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "Today's Patients",
                      todaysPatients.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      "This Month",
                      totalAppointmentsThisMonth.toString(),
                      subtitle: "Appointments",
                      icon: Icons.calendar_today,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      "Earnings",
                      "₹${monthlyEarnings.toStringAsFixed(0)}",
                      subtitle: "This Month",
                      icon: Icons.currency_rupee,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---------------------- ABOUT SECTION ---------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "About Doctor",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF00372E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                ),
                child: Text(
                  widget.doctor.about,
                  style: GoogleFonts.poppins(
                      color: Colors.white70, height: 1.5, fontSize: 14),
                ),
              ),
            ),



            const SizedBox(height: 30),

            // ---------------------- WEEKLY SCHEDULE ------------------
            buildWeeklySchedule(widget.doctor.schedule),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, {String? subtitle, IconData? icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  // ----------------------- WEEKLY SCHEDULE UI ------------------
  Widget buildWeeklySchedule(Map<String, dynamic> schedule) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Weekly Schedule",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          ...schedule.entries.map((clinic) {
            final clinicId = clinic.key;
            final days = clinic.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00372E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.withOpacity(0.5)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Clinic ID: $clinicId",
                      style: GoogleFonts.poppins(
                          color: Colors.cyanAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ...days.entries.map((day) {
                    final dayName = day.key;
                    final dayData = day.value;
                    final slots = dayData["slots"] as List;
                    final closed = dayData["isClosed"] == "true";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dayName,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),

                          if (closed)
                            Text("Closed",
                                style: GoogleFonts.poppins(
                                    color: Colors.redAccent, fontSize: 13))
                          else
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: slots.map((s) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                        Colors.cyanAccent.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    "${s['open']} - ${s['close']} (${s['patients']} patients)",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    );
                  }).toList()
                ],
              ),
            );
          }).toList()
        ],
      ),
    );
  }
}
