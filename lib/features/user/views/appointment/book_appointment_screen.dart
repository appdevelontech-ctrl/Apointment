import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../../shared/services/api_service.dart';
import '../../../../shared/utils/preferences.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final int fee;
  final String selectedTime;
  final String selectedDate;

  const BookAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.fee,
    required this.selectedTime,
    required this.selectedDate,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final TextEditingController requirementCtrl = TextEditingController();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  loadUser() async {
    userData = await PrefUtils.getUserData();
    setState(() {});
  }

  Future<void> bookNow() async {
    if (requirementCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📝 Please describe your health issue")),
      );
      return;
    }

    final payload = {
      "userId": userData!["userId"],
      "fullname": userData!["name"],
      "phone": userData!["phone"],
      "email": userData!["email"],
      "requirement": requirementCtrl.text.trim(),
      "totalAmount": widget.fee,
      "date": widget.selectedDate,
      "time": widget.selectedTime,
      "doctorId": widget.doctorId
    };

    final res = await http.post(
      Uri.parse("${ApiService.baseUrl}/book-appointment"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );



    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Appointment Booked Successfully"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Something went wrong"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Appointment"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          padding: const EdgeInsets.only(left: 20),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👨‍⚕️ Doctor: ${widget.doctorName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
            const SizedBox(height: 6),

            Text("📅 Date: ${widget.selectedDate}", style: const TextStyle(fontSize: 16)),
            Text("⏰ Time: ${widget.selectedTime}", style: const TextStyle(fontSize: 16)),
            Text("💰 Fee: ₹${widget.fee}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 17)),

            const SizedBox(height: 25),

            const Text("Describe your health issue", style: TextStyle(fontSize: 15)),

            const SizedBox(height: 10),

            TextField(
              controller: requirementCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Example: Fever, cough from 2 days...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: bookNow,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Confirm Appointment", style: TextStyle(fontSize: 18,color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
