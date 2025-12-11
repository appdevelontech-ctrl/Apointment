import 'package:flutter/material.dart';

import 'appoinment_detials.dart';

// THEME COLORS
const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class AppointmentHistoryScreen extends StatelessWidget {
  AppointmentHistoryScreen({super.key});

  // 🚀 Dummy List Data (Later you can replace with API)
  final List<Map<String, dynamic>> appointmentData = [
    {
      "date": "29 JUL",
      "year": "2025",
      "doctor": "Dr. Amit Baranwal",
      "specialist": "Dentist",
      "clinic": "Dental Cure Dental N Implant Centre",
      "time": "01:15 PM",
      "day": "Tuesday",
      "type": "In-clinic consultation",
      "status": "Completed"
    },
    {
      "date": "14 JAN",
      "year": "2025",
      "doctor": "Dr. Kunal Verma",
      "specialist": "Cardiologist",
      "clinic": "Max Super Speciality Hospital",
      "time": "10:30 AM",
      "day": "Saturday",
      "type": "Video consultation",
      "status": "Completed"
    },
    {
      "date": "04 AUG",
      "year": "2020",
      "doctor": "Dr. Abhishek Sinha",
      "specialist": "Dentist",
      "clinic": "Smile Dentistry Clinic",
      "time": "11:00 AM",
      "day": "Monday",
      "type": "In-clinic consultation",
      "status": "Cancelled"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTeal),
          padding: const EdgeInsets.only(left: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0.6,
        title: const Text(
          "Appointments History",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: kTealDark,
          ),
        ),
        centerTitle: false,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        itemCount: appointmentData.length,
        itemBuilder: (context, index) {
          final data = appointmentData[index];

          // Year heading sirf tab dikhayenge jab year change ho
          String year = data["year"];
          String? prevYear =
          index > 0 ? appointmentData[index - 1]["year"] as String : null;
          bool showYearHeader = (index == 0) || (year != prevYear);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showYearHeader) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    year,
                    style: const TextStyle(
                      color: kTealDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],

              _appointmentCard(context, data),
              const SizedBox(height: 6),
            ],
          );
        },
      ),
    );
  }

  // 🔷 CARD WIDGET
  Widget _appointmentCard(BuildContext context, Map<String, dynamic> data) {
    final String status = data["status"] ?? "";
    final bool isCancelled = status.toLowerCase() == "cancelled";
    final bool isCompleted = status.toLowerCase() == "completed";

    Color statusColor = isCompleted
        ? Colors.green.shade700
        : isCancelled
        ? Colors.red.shade700
        : Colors.orange.shade700;

    Color statusBg = isCompleted
        ? Colors.green.shade50
        : isCancelled
        ? Colors.red.shade50
        : Colors.orange.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kTeal.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📅 DATE BOX
          _dateBox(data),

          const SizedBox(width: 12),

          // 🔹 MAIN DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👨‍⚕️ Doctor + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services_rounded,
                        size: 18, color: kTealDark),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        data["doctor"] ?? "",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTealDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  data["specialist"] ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // 🕒 Time + Day
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${data["day"] ?? ''}, ${data["time"] ?? ''}",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 🏥 Clinic
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data["clinic"] ?? "",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // 💻 Type (In-clinic / Video)
                if (data["type"] != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.video_camera_front_outlined,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        data["type"],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),

                // STATUS CHIP + BUTTONS
                Row(
                  children: [
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle_outline
                                : isCancelled
                                ? Icons.cancel_outlined
                                : Icons.schedule,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // 🔁 Book again
                    TextButton(
                      onPressed: () {
                        // later: open booking flow with same doctor
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                      ),
                      child: const Text(
                        "Book again",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kTealDark,
                        ),
                      ),
                    ),

                    // 🔍 View Details
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppointmentDetailsScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                      child: const Text(
                        "View details",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kTeal,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📆 DATE BOX WIDGET
  Widget _dateBox(Map<String, dynamic> data) {
    final parts = (data["date"] as String).split(" "); // "29 JUL"
    final day = parts.isNotEmpty ? parts[0] : "";
    final month = parts.length > 1 ? parts[1] : "";

    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: kTeal.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kTeal.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kTealDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            month,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kTeal,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
