import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../shared/services/api_service.dart';
import '../../../../shared/utils/preferences.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final int fee;
  final String selectedTime;       // "10:00 AM - 06:00 PM"
  final String selectedDate;       // "yyyy-MM-dd"
  final String selectedHospitalId; // hosId

  const BookAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.fee,
    required this.selectedTime,
    required this.selectedDate,
    required this.selectedHospitalId,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  // ================= CONTROLLERS =================
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController weightCtrl = TextEditingController();
  final TextEditingController requirementCtrl = TextEditingController();

  Map<String, dynamic>? userData;
  bool isBooking = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    userData = await PrefUtils.getUserData();

    nameCtrl.text = userData?["name"] ?? "";
    emailCtrl.text = userData?["email"] ?? "";
    phoneCtrl.text = userData?["phone"] ?? "";
    ageCtrl.text = userData?["age"] ?? "";
    weightCtrl.text = userData?["weight"] ?? "";

    setState(() {});
  }

  // ================= BOOK APPOINTMENT =================
  Future<void> bookNow() async {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        requirementCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required details")),
      );
      return;
    }

    setState(() => isBooking = true);

    final payload = {
      "fullname": nameCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),

      "userId": userData!["userId"],
      "senderId": userData!["userId"],

      "age": ageCtrl.text.trim(),
      "weight": weightCtrl.text.trim(),
      "gender": userData!["gender"] ?? "1",

      "requirement": requirementCtrl.text.trim(),
      "totalAmount": widget.fee,

      // 🔥 BACKEND VERIFIED FORMAT
      "date": widget.selectedDate,       // yyyy-MM-dd
      "time": widget.selectedTime,       // "10:00 AM - 06:00 PM"

      "doctorId": widget.doctorId,
      "hosId": widget.selectedHospitalId,
    };

    try {
      final res = await http.post(
        Uri.parse("${ApiService.baseUrl}/book-appointment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final body = jsonDecode(res.body);

      if (body["success"] == true) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"] ?? "Booking failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error")),
      );
    } finally {
      setState(() => isBooking = false);
    }
  }

  // ================= SUCCESS DIALOG =================
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.teal, size: 72),
              const SizedBox(height: 16),
              const Text(
                "Appointment Booked",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Your appointment with ${widget.doctorName} is confirmed.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst); // go Home
                  },
                  child: const Text(
                    "Go to Home",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Appointment"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _input("Full Name", nameCtrl,  keyboard: TextInputType.name),
            _input("Email", emailCtrl, keyboard: TextInputType.emailAddress),
            _input("Phone", phoneCtrl, keyboard: TextInputType.phone, readOnly: true),
            _input("Age", ageCtrl, keyboard: TextInputType.number),
            _input("Weight", weightCtrl, keyboard: TextInputType.number),
            _input("Health Issue", requirementCtrl, maxLines: 3),

            const SizedBox(height: 16),
            _infoRow("Doctor", widget.doctorName),
            _infoRow("Date", widget.selectedDate),
            _infoRow("Time", widget.selectedTime),
            _infoRow("Fee", "₹${widget.fee}"),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isBooking ? null : bookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Confirm Appointment",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= REUSABLE WIDGETS =================
  Widget _input(
      String label,
      TextEditingController controller, {
        TextInputType keyboard = TextInputType.text,
        bool readOnly = false,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}
