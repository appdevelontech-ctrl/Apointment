import 'package:flutter/material.dart';

const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class DoctorDetailScreen extends StatelessWidget {
  final dynamic data;
  const DoctorDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: kTeal,
        elevation: 0,
        title: Text(data.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 💬 Chat Row Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {}, // Later: WhatsApp deep link
                    icon: const Icon(Icons.whatshot_sharp, color: Colors.green),
                    label: const Text("Chat", style: TextStyle(color: Colors.green)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openMessageDialog(context),
                    icon: const Icon(Icons.mail, color: kTealDark),
                    label: const Text("Send Message", style: TextStyle(color: kTealDark)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kTealDark),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {},
              child: const Center(
                child: Text("Book Appointment",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),

      // 🟢 BODY
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 40, backgroundImage: NetworkImage(data.image)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTealDark)),
                  const SizedBox(height: 6),
                  Text(data.desc, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(children: const [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(" 4.7 Rating", style: TextStyle(fontSize: 12)),
                  ])
                ]),
              )
            ],
          ),

          const SizedBox(height: 18),
          _sectionTitle("About Doctor"),
          _infoText(
              "Dr. ${data.name} is a certified and highly experienced ${data.desc}. He has successfully consulted 5000+ patients and is associated with premium hospitals such as Fortis, Medanta, Max & Apollo."),

          _sectionTitle("Education"),
          _infoText(
              "• MBBS (AIIMS Delhi)\n• MD (Cardiology) – PGI Chandigarh\n• Fellowship in Critical Care – USA"),

          _sectionTitle("Specialization"),
          _infoText("• Cardiology\n• Diabetes & Hypertension\n• Chest Pain & ECG\n• Critical Care Treatment"),

          _sectionTitle("Diseases Treated"),
          _infoText(
              "• High Blood Pressure\n• Chest Pain\n• Heart Attack Recovery\n• Rapid Heartbeat\n• Diabetes & Cholesterol"),

          _sectionTitle("Hospital Availability"),
          _infoText(
              "• Max Super Speciality Hospital – Mon/Wed/Fri\n• Fortis Hospital – Tue/Thu/Sat"),

          _sectionTitle("Consultation Timings"),
          _infoText("🕒 10:00 AM to 2:00 PM & 5:00 PM to 8:00 PM"),

          _sectionTitle("Consultation Fees"),
          _infoText("💰 ₹ 500 - ₹ 1200 (Depending on Hospital)"),

          _sectionTitle("Experience"),
          _infoText("🟢 10+ Years"),
        ],
      ),
    );
  }

  // 📌 Message Dialog
  void _openMessageDialog(BuildContext context) {
    TextEditingController msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Send Message", style: TextStyle(color: kTealDark, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: msgCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Type your message…",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kTeal),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("We will contact you soon 😊"),
                    backgroundColor: kTealDark,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 6),
      child:
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTealDark)));

  Widget _infoText(String text) => Text(
    text,
    style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
  );
}
