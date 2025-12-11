import 'package:flutter/material.dart';

const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,

        title: const Text("Appointment Details", style: TextStyle(fontWeight: FontWeight.w600,color: kTealDark)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          _appointmentInfoCard(),

          const SizedBox(height: 16),

          _statusCard(),

          const SizedBox(height: 16),

          _paymentInfo(),

          const SizedBox(height: 16),

          _visitSummary(),

          const SizedBox(height: 16),

          _prescriptionCard(),

          const SizedBox(height: 25),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text("Book Again", style: TextStyle(color: kTealDark, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () {},
                  child: const Text("Get Invoice", style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  // 💚 1. APPOINTMENT INFO
  Widget _appointmentInfoCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: [
        // DATE + TIME
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFEFF9F8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(children: [
                Icon(Icons.calendar_today_rounded, size: 18, color: kTealDark),
                SizedBox(width: 6),
                Text("04 Aug 2020", style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
              Row(children: [
                Icon(Icons.access_time_filled_rounded, size: 18, color: kTealDark),
                SizedBox(width: 4),
                Text("11:00 AM", style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ),

        // DOCTOR INFO
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "https://cdn-icons-png.flaticon.com/512/3048/3048127.png",
              height: 55,
              width: 55,
              fit: BoxFit.cover,
            ),
          ),
          title: const Text("Dr. Abhishek Sinha",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTealDark)),
          subtitle: const Text(
            "BDS, MDS - Oral Medicine\nCosmetic Dentist, Dental Surgeon",
            style: TextStyle(fontSize: 12, height: 1.3),
          ),
        ),

        Divider(color: Colors.grey.shade200),

        // HOSPITAL
        ListTile(
          leading: const Icon(Icons.local_hospital_rounded, size: 35, color: kTealDark),
          title: const Text("Dentistry", style: TextStyle(fontWeight: FontWeight.bold, color: kTealDark)),
          subtitle: const Text("UGF 36, Regal Plaza, Lucknow", style: TextStyle(fontSize: 12)),
          trailing: Text(
            "Get Directions",
            style: TextStyle(
              fontSize: 12,
              decoration: TextDecoration.underline,
              color: kTealDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ]),
    );
  }

  // 🔴 2. Status Card
  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              Icon(Icons.cancel, size: 14, color: Colors.red.shade700),
              const SizedBox(width: 4),
              Text("Cancelled", style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
            ]),
          ),
          const Spacer(),
          const Text("ID: 10429799",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        ]),
        const SizedBox(height: 10),
        const Text(
          "We have sent you an SMS with the appointment details.",
          style: TextStyle(fontSize: 13, height: 1.3),
        ),
      ]),
    );
  }

  // 💳 3. PAYMENT INFO
  Widget _paymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text("Payment Info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kTealDark)),
        SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Consultation Fee:", style: TextStyle(fontSize: 13)),
          Text("₹ 450", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  // 📄 4. VISIT SUMMARY
  Widget _visitSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text("Visit Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kTealDark)),
        SizedBox(height: 8),
        Text("• Diagnosis: Tooth Sensitivity", style: TextStyle(fontSize: 13)),
        Text("• Treatment Suggested: Root Canal", style: TextStyle(fontSize: 13)),
        Text("• Follow Up: 7 Days Later", style: TextStyle(fontSize: 13)),
      ]),
    );
  }

  // 💊 5. PRESCRIPTION
  Widget _prescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text("Prescription", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kTealDark)),
        SizedBox(height: 8),
        Text("• Dolo 650 mg (1-0-1)", style: TextStyle(fontSize: 13)),
        Text("• Sensodent-K Gel (Apply 2 times)", style: TextStyle(fontSize: 13)),
      ]),
    );
  }

  // CARD DECORATION STYLE
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kTeal.withOpacity(0.15)),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    );
  }
}
