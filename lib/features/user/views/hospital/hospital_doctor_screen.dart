import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../shared/services/api_service.dart';
import '../doctor/doctor_detial_screen.dart'; // <<-- If you have doctor page

class HospitalDoctorsScreen extends StatefulWidget {
  final String hospitalId;
  const HospitalDoctorsScreen({super.key, required this.hospitalId});

  @override
  State<HospitalDoctorsScreen> createState() => _HospitalDoctorsScreenState();
}

class _HospitalDoctorsScreenState extends State<HospitalDoctorsScreen> {
  Map<String, dynamic>? hospital;
  List doctors = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHospitalDetails();
  }

  Future<void> fetchHospitalDetails() async {
    final res = await http.get(Uri.parse(
        "${ApiService.baseUrl}/get-vendor/${widget.hospitalId}"));

    if (res.statusCode == 200) {
      hospital = jsonDecode(res.body)["Mpage"];

      /// Fetch doctors after hospital details
      fetchDoctors();
    }
  }

  Future<void> fetchDoctors() async {
    final res = await http.get(Uri.parse(
        "${ApiService.baseUrl}/all-hospital-doctor?headId=${widget.hospitalId}"));

    if (res.statusCode == 200) {
      doctors = jsonDecode(res.body)["users"];
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Hospital Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _hospitalCard(),
            const SizedBox(height: 20),
            _sectionTitle("Doctors Available"),
            const SizedBox(height: 10),
            ...doctors.map((d) => _doctorCard(d)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _hospitalCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: hospital!["profile"] != null
                    ? "${ApiService.baseUrl}/${hospital!["profile"]}"
                    : "https://cdn-icons-png.flaticon.com/512/3103/3103472.png",
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),

            Text(hospital!["username"],
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.teal),
                Expanded(
                  child: Text(hospital!["location"] ?? "",
                      style: TextStyle(color: Colors.grey.shade600)),
                )
              ],
            ),

            if (hospital!["about"] != null && hospital!["about"].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  hospital!["about"].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _doctorCard(dynamic d) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => DoctorDetailsScreen(doctorId: d["_id"])
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: d["profile"] != null
                  ? NetworkImage("${ApiService.baseUrl}/${d["profile"]}")
                  : const NetworkImage("https://cdn-icons-png.flaticon.com/512/149/149071.png"),
            ),
            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d["username"], style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 4),
                  Text(d["subDepartments"]?.join(", ") ?? "",
                      style: TextStyle(color: Colors.grey.shade700)),

                  const SizedBox(height: 6),
                  Text("${d["Experience"] ?? 0} Years Experience | ₹${d["Salary"] ?? '--'}",
                      style: const TextStyle(fontSize: 12, color: Colors.teal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
