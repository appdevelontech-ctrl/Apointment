import 'dart:convert';
import 'package:appointment_app/features/hospital/services/hospital_api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'hospital_doctor_screen.dart';
import 'package:geolocator/geolocator.dart';

class HospitalFilterScreen extends StatefulWidget {
  const HospitalFilterScreen({super.key});

  @override
  State<HospitalFilterScreen> createState() => _HospitalFilterScreenState();
}

class _HospitalFilterScreenState extends State<HospitalFilterScreen> {
  List hospitals = [];
  bool loading = true;
  bool filterExpanded = true;

  // Filters
  String? selectedCity;
  String selectedDepartment = "All";
  String? selectedDistance;

  List departments = ["All"];
  List cities = [];

  Position? userPosition;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await getUserLocation();
    await fetchHospitals();
  }

  /// 📍 GET USER LOCATION
  Future<void> getUserLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) return;

      userPosition = await Geolocator.getCurrentPosition();
    } catch (_) {}
  }

  /// 📌 CALCULATE DISTANCE
  double calculateDistance(double lat, double lng) {
    if (userPosition == null) return 0;
    return Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      lat,
      lng,
    ) /
        1000;
  }

  /// 🔥 API CALL
  Future<void> fetchHospitals() async {
    setState(() => loading = true);

    String api = "${ApiService.baseUrl}/all-hospital?page=1&limit=50";

    if (selectedCity != null) api += "&city=$selectedCity";
    if (selectedDepartment != "All") api += "&department=$selectedDepartment";

    final response = await http.get(Uri.parse(api));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      hospitals = (data["users"] ?? []).map((h) {
        double? lat = double.tryParse(h["lat"] ?? "");
        double? lng = double.tryParse(h["lng"] ?? "");

        return {
          ...h,
          "distance": (lat != null && lng != null)
              ? calculateDistance(lat, lng).toStringAsFixed(1)
              : "--"
        };
      }).toList();

      if (selectedDistance != null) {
        int limit = int.parse(selectedDistance!.replaceAll(" km", ""));
        hospitals = hospitals
            .where((e) => double.tryParse(e["distance"])! <= limit)
            .toList();
      }

      cities = hospitals.map((e) => e["city"]).where((e) => e != null).toSet().toList();
      departments = ["All", ...(data["allSubDepartments"] ?? [])];

      setState(() => loading = false);
    }
  }

  Future<void> resetFilters() async {
    setState(() {
      selectedCity = null;
      selectedDistance = null;
      selectedDepartment = "All";
    });
    fetchHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Find Hospitals"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          /// 🔽 FILTER BOX
          Padding(
            padding: const EdgeInsets.all(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(filterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                        onPressed: () => setState(() => filterExpanded = !filterExpanded),
                      ),
                    ],
                  ),
                  if (filterExpanded) ...[
                    const SizedBox(height: 12),
                    _filters(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: resetFilters,
                        child: const Text("Reset Filters", style: TextStyle(color: Colors.red)),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : hospitals.isEmpty
                ? const Center(child: Text("No matching hospitals found"))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: hospitals.length,
              itemBuilder: (_, i) => _hospitalCard(hospitals[i]),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧩 FILTER UI
  Widget _filters() => Column(
    children: [
      _dropdown("City", selectedCity, ["All", ...cities], (v) {
        selectedCity = (v == "All") ? null : v;
        fetchHospitals();
      }),

      const SizedBox(height: 10),

      _dropdown("Department", selectedDepartment, departments, (v) {
        selectedDepartment = v!;
        fetchHospitals();
      }),

      const SizedBox(height: 10),

      _dropdown("Distance", selectedDistance, ["5 km", "10 km", "20 km", "50 km"], (v) {
        selectedDistance = v;
        fetchHospitals();
      }),
    ],
  );

  /// 📥 FIXED DROPDOWN
  Widget _dropdown(
      String label,
      String? value,
      List items,
      Function(String?) onSelect,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        borderRadius: BorderRadius.circular(12),
        underline: const SizedBox(),

        // 🔥 Prevent crash: if value not found → null
        value: (value != null && items.contains(value)) ? value : null,

        hint: Text(
          "Select $label",
          style: TextStyle(color: Colors.grey.shade600),
        ),

        items: items.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
            value: item.toString(),
            child: Text(
              item.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),

        onChanged: (val) {
          // 🧠 "All" ko null treat karna
          if (val == "All") {
            onSelect(null);
          } else {
            onSelect(val);
          }
        },
      ),
    );
  }


  /// 🏥 CARD UI
  Widget _hospitalCard(h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              h["profile"] != null ? "https://hospitalquee.onrender.com/${h["profile"]}" : "https://cdn-icons-png.flaticon.com/512/3103/3103472.png",
              height: 70,
              width: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h["username"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${h["distance"]} km away", style: TextStyle(color: Colors.blueGrey)),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          if (h["phone"] == null) return;

                          final call = Uri(scheme: "tel", path: h["phone"]);
                          await launchUrl(call);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: const BorderSide(color: Colors.teal),
                        ),
                        child: const Text("Call"),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HospitalDoctorsScreen(hospitalId: h["_id"])),
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        child: const Text("View",style: TextStyle(color: Colors.white),),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
