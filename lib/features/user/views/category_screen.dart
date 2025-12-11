import 'package:flutter/material.dart';

const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class CategoryDetailScreen extends StatelessWidget {
  final dynamic data; // SearchItem type (name, image, type, desc)

  const CategoryDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String name = data.name;
    final String desc = data.desc;
    final String image = data.image;

    final symptoms = _getSymptoms(name);
    final treatments = _getTreatments(name);
    final doctors = _getDoctors(name);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: kTeal,
        elevation: 0,
        title: Text(name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      bottomNavigationBar: _bottomActions(context, name),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Icon + Title
          Row(
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: kTeal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.network(image, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kTealDark)),
                    const SizedBox(height: 6),
                    Text(desc,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          _sectionTitle("What is $name?"),
          _infoText(
              "$name is a medical speciality dealing with ${_aboutText(name)}. "
                  "Specialist doctors diagnose, treat and help you manage these problems "
                  "using medicines, lifestyle changes and advanced procedures."),

          _sectionTitle("Common Symptoms"),
          _chipsList(symptoms),

          _sectionTitle("Treatments & Procedures"),
          _bulletList(treatments),

          _sectionTitle("When should you see a $name doctor?"),
          _infoText(
              "• Symptoms lasting more than 1–2 weeks\n"
                  "• Daily activities affected\n"
                  "• Severe or sudden pain / discomfort\n"
                  "• Symptoms coming again and again\n"
                  "• You are not getting relief by basic medicines"),

          _sectionTitle("Top Doctors for $name"),
          ...doctors.map((d) => _doctorTile(d)).toList(),
        ],
      ),
    );
  }

  // ---------- BOTTOM ACTION BAR ----------
  Widget _bottomActions(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.people_alt, size: 18, color: kTealDark),
              label: const Text("Find Doctors",
                  style: TextStyle(color: kTealDark, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kTealDark),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // yaha baad me filter doctor list screen open kar sakte ho
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                    Text("Showing doctors for $name (demo action)..."),
                    backgroundColor: kTealDark,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.help_outline,
                  size: 18, color: kTealDark),
              label: const Text("Ask Free Question",
                  style: TextStyle(color: kTealDark, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kTealDark),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _openQuestionDialog(context, name),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kTeal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                // future: category wise booking screen_open
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                    Text("Booking for $name will be available soon 😊"),
                    backgroundColor: kTealDark,
                  ),
                );
              },
              child: const Text(
                "Book Now",
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- QUESTION DIALOG ----------
  void _openQuestionDialog(BuildContext context, String name) {
    final TextEditingController msg = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text("Ask about $name",
            style: const TextStyle(color: kTealDark)),
        content: TextField(
          controller: msg,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Write your symptoms or question...",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel",
                style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kTeal),
            child: const Text("Send",
                style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Doctor will reply you soon 😊"),
                backgroundColor: kTealDark,
              ));
            },
          )
        ],
      ),
    );
  }

  // ---------- CONTENT HELPERS ----------

  String _aboutText(String name) {
    switch (name.toLowerCase()) {
      case "orthopaedic":
        return "bones, joints, muscles and spine problems like arthritis, back pain and fractures";
      case "gynecology":
      case "gynaecology":
        return "women's health, periods, pregnancy and reproductive issues";
      case "neurology":
        return "brain, nerves and spine issues like migraine, seizures and paralysis";
      case "cardiologist":
      case "cardiology":
        return "heart and blood vessel diseases like chest pain and BP issues";
      default:
        return "the related health issues and conditions in this speciality";
    }
  }

  List<String> _getSymptoms(String name) {
    switch (name.toLowerCase()) {
      case "orthopaedic":
        return [
          "Joint pain & stiffness",
          "Knee / back pain",
          "Swelling in joints",
          "Difficulty in walking",
        ];
      case "gynecology":
        return [
          "Irregular periods",
          "Severe period pain",
          "White discharge",
          "Pregnancy related doubts",
        ];
      case "neurology":
        return [
          "Frequent headache / migraine",
          "Weakness of one side body",
          "Fits or seizures",
          "Loss of balance",
        ];
      default:
        return [
          "Pain or discomfort",
          "Long lasting symptoms",
          "Daily routine affected",
        ];
    }
  }

  List<String> _getTreatments(String name) {
    switch (name.toLowerCase()) {
      case "orthopaedic":
        return [
          "X-Ray & MRI based diagnosis",
          "Physiotherapy & exercises",
          "Joint replacement surgeries",
          "Arthroscopy & spine procedures",
        ];
      case "gynecology":
        return [
          "Period & hormonal treatment",
          "Pregnancy care & delivery",
          "PCOD / infertility management",
          "Minor & major gynae surgeries",
        ];
      case "neurology":
        return [
          "EEG / MRI brain",
          "Migraine treatment",
          "Stroke & paralysis management",
          "Epilepsy treatment",
        ];
      default:
        return [
          "Doctor consultation & checkup",
          "Diagnostic tests",
          "Medicines & lifestyle advice",
          "Surgery if required",
        ];
    }
  }

  List<Map<String, String>> _getDoctors(String name) {
    switch (name.toLowerCase()) {
      case "orthopaedic":
        return [
          {"name": "Dr. Rohan Verma", "detail": "Orthopaedic • 12 yrs exp"},
          {"name": "Dr. Nidhi Kapoor", "detail": "Knee & Hip Specialist"},
        ];
      case "gynecology":
        return [
          {"name": "Dr. Priya Sharma", "detail": "Gynaecologist • 10 yrs exp"},
          {"name": "Dr. Neha Agarwal", "detail": "Fertility & High-risk pregnancy"},
        ];
      case "neurology":
        return [
          {"name": "Dr. Abhishek Rao", "detail": "Neurologist • 15 yrs exp"},
          {"name": "Dr. Irfan Khan", "detail": "Stroke & Epilepsy specialist"},
        ];
      default:
        return [
          {"name": "Dr. Expert 1", "detail": "$name Specialist"},
          {"name": "Dr. Expert 2", "detail": "$name Specialist"},
        ];
    }
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 16, color: kTealDark),
    ),
  );

  Widget _infoText(String text) => Text(
    text,
    style: const TextStyle(
        fontSize: 13, color: Colors.black87, height: 1.4),
  );

  Widget _chipsList(List<String> items) => Wrap(
    spacing: 8,
    runSpacing: 6,
    children: items
        .map(
          (e) => Chip(
        label: Text(e, style: const TextStyle(fontSize: 11)),
        backgroundColor: kTeal.withOpacity(0.08),
        labelStyle: const TextStyle(color: kTealDark),
      ),
    )
        .toList(),
  );

  Widget _bulletList(List<String> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items
        .map(
          (e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ",
                style: TextStyle(fontSize: 13, height: 1.4)),
            Expanded(
              child: Text(e,
                  style: const TextStyle(
                      fontSize: 13, height: 1.4)),
            ),
          ],
        ),
      ),
    )
        .toList(),
  );

  Widget _doctorTile(Map<String, String> d) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
              "https://cdn-icons-png.flaticon.com/512/1077/1077012.png"),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d["name"]!,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kTealDark)),
                const SizedBox(height: 2),
                Text(d["detail"]!,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54)),
              ]),
        ),
        const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.grey),
      ],
    ),
  );
}
