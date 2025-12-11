import 'package:flutter/material.dart';

const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class HospitalDetailScreen extends StatelessWidget {
  final dynamic data;
  const HospitalDetailScreen({super.key, required this.data});

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

      bottomNavigationBar: _actionBar(context),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(data.image, height: 180, fit: BoxFit.cover),
          ),

          const SizedBox(height: 12),
          Text(data.name,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: kTealDark)),
          Row(children: [
            const Icon(Icons.location_on, size: 18, color: kTealDark),
            Expanded(child: Text(data.desc, style: const TextStyle(fontSize: 13))),
          ]),

          const SizedBox(height: 20),
          _title("About Hospital"),
          _info("A multi-speciality hospital equipped with advanced surgical units, "
              "24x7 emergency care, ICU, NICU & diagnostic center. Providing modern treatment "
              "for cardiology, neurology, pediatrics & more."),

          _title("Facilities"),
          _list(["24x7 Emergency Unit", "ICU + NICU", "Pharmacy + Diagnostics", "Private AC Rooms", "Cashless Insurance"]),

          _title("Services & Departments"),
          _list(["Cardiology", "Neurology", "Orthopedics", "Gynecology", "Pediatrics", "General Surgery"]),

          _title("Top Doctors"),
          _doctorPreview(),
        ],
      ),
    );
  }

  // ACTION BAR (CALL, WHATSAPP, MESSAGE)
  Widget _actionBar(BuildContext ctx) => Container(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      _miniButton(Icons.call, "Call", Colors.green,
              () {/* Future phone call */}),
      const SizedBox(width: 10),
      _miniButton(Icons.whatshot_sharp, "WhatsApp", Colors.green,
              () {/* WhatsApp Chat */}),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kTeal),
          onPressed: () => _messageDialog(ctx),
          child: const Text("Send Message", style: TextStyle(color: Colors.white)),
        ),
      ),
    ]),
  );

  Widget _miniButton(IconData icon, String text, Color c, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        icon: Icon(icon, color: c, size: 18),
        label: Text(text, style: TextStyle(color: c, fontSize: 13)),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(side: BorderSide(color: c), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  // MESSAGE DIALOG
  void _messageDialog(BuildContext context) {
    TextEditingController msg = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Write Message", style: TextStyle(color: kTealDark)),
        content: TextField(
          controller: msg,
          maxLines: 4,
          decoration: InputDecoration(hintText: "Type your query...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
        actions: [
          TextButton(child: const Text("Cancel", style: TextStyle(color: Colors.red)), onPressed: ()=> Navigator.pop(context)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kTeal),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("We will contact you soon 😊"), backgroundColor: kTealDark));
            },
            child: const Text("Send", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 6),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTealDark)),
  );

  Widget _info(String t) => Text(t, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87));

  Widget _list(List<String> items) => Column(
    children: items.map((e)=> Row(children:[
      const Text("• ", style: TextStyle(fontSize: 13)),
      Expanded(child: Text(e, style: const TextStyle(fontSize: 13))),
    ])).toList(),
  );

  Widget _doctorPreview() => Column(children: [
    _docRow("Dr. Abhishek Rao", "Cardiologist"),
    _docRow("Dr. Priya Sharma", "Neurologist"),
    _docRow("Dr. Rohit Mehta", "Orthopedic"),
  ]);

  Widget _docRow(String n, String s) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children:[
      const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/1077/1077012.png")),
      const SizedBox(width: 12),
      Expanded(child: Text("$n • $s", style: const TextStyle(fontSize: 13))),
      const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey),
    ]),
  );
}
