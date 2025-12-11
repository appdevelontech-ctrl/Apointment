import 'package:flutter/material.dart';

const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class MedicalRecords extends StatelessWidget {
  const MedicalRecords({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _uploadButton(),
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
        title: const Text("Medical Records", style: TextStyle(fontWeight: FontWeight.w600,color: kTealDark)),
      ),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _yearHeader("2021"),
          _recordCard(
            date: "18", month: "JUN",
            doctor: "Dr. Prasanna T Y",
            type: "Orthopedic",
            records: ["Prescription", "Bill"],
            name: "Shalu Chauhan",
            isNew: false,
            context: context,
          ),

          _yearHeader("2020"),
          _recordCard(
            date: "23", month: "AUG",
            doctor: "Dr. Amrita Aneja",
            type: "Eye and Vision",
            records: ["Prescription"],
            name: "Shalu Chauhan",
            isNew: true,
            context: context,
          ),
          _recordCard(
            date: "23", month: "AUG",
            doctor: "Dr. Amrita Aneja",
            type: "Video Consultation",
            records: ["Bill"],
            name: "Shalu Chauhan",
            isNew: false,
            context: context,
          ),
          _recordCard(
            date: "12", month: "AUG",
            doctor: "Dr. Aditi Agarwal",
            type: "Eye and Vision",
            records: ["Bill", "Prescription"],
            name: "Shalu Chauhan",
            isNew: true,
            context: context,
          ),
        ],
      ),
    );
  }

  // 📌 Floating Upload Button
  Widget _uploadButton() {
    return FloatingActionButton.extended(
      backgroundColor: kTeal,
      elevation: 5,
      onPressed: () {},
      icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
      label: const Text("Upload Records", style: TextStyle(color: Colors.white)),
    );
  }

  // 📌 Year Header Widget
  Widget _yearHeader(String year) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.grey.shade300,
      child: Text(
        year,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      ),
    );
  }

  // 📌 Medical Record Card
  Widget _recordCard({
    required String date,
    required String month,
    required String doctor,
    required String type,
    required List<String> records,
    required String name,
    required bool isNew,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () => _openBottomSheet(context, doctor, type, records),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 📌 Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: kTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kTeal.withOpacity(0.4)),
            ),
            child: Column(children: [
              Text(date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(month, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ]),
          ),
          const SizedBox(width: 15),

          // 📌 Appointment Details
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text("Consulted $doctor", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Text("New", style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
              ]),
              Text(type, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text("Records (${records.length}) • $name",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: records.map((e) => _recordTag(e)).toList(),
              )
            ]),
          ),

          const Icon(Icons.chevron_right, color: Colors.black45),
        ]),
      ),
    );
  }

  // 📌 Document Type Tags
  Widget _recordTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: kTeal.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(color: kTealDark, fontSize: 11)),
    );
  }

  // 📌 Bottom Sheet for View / Download
  void _openBottomSheet(BuildContext context, String doctor, String type, List<String> files) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Records from $doctor", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTealDark)),
            Text(type, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 15),
            ...files.map((e) => ListTile(
              leading: const Icon(Icons.description_rounded, color: kTealDark),
              title: Text(e),
              trailing: const Icon(Icons.download_rounded, color: kTeal),
              onTap: () {},
            )),
            const SizedBox(height: 10),
          ]),
        );
      },
    );
  }
}
