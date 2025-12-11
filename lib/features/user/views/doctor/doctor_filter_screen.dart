import 'dart:convert';
import 'package:appointment_app/features/user/views/doctor/doctor_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/services/api_service.dart';
import 'doctor_detial_screen.dart';

class DoctorFilterScreen extends StatefulWidget {
  const DoctorFilterScreen({super.key});

  @override
  State<DoctorFilterScreen> createState() => _DoctorFilterScreenState();
}

class _DoctorFilterScreenState extends State<DoctorFilterScreen> {
  List doctors = [];
  List filteredDoctors = [];
  List departments = ["All"];
  List cities = [];

  bool loading = true;
  bool filterExpanded = true;

  String? selectedCity;
  String? selectedDepartment = "All";
  String? selectedExperience;
  String? selectedDistance;

  double priceValue = 800; // slider range ₹0 - ₹2000

  double? userLat;
  double? userLng;

  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLocation();
    fetchDoctors();
  }

  Future<void> _getLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition();
    userLat = pos.latitude;
    userLng = pos.longitude;
  }

  Future<void> fetchDoctors() async {
    setState(() => loading = true);

    String api = "${ApiService.baseUrl}/all-vendors?page=1&limit=50";

    if (selectedCity != null && selectedCity!.isNotEmpty && selectedCity != "All") api += "&city=$selectedCity";
    if (selectedDepartment != null && selectedDepartment!.isNotEmpty && selectedDepartment != "All") api += "&department=$selectedDepartment";
    if (selectedExperience != null) api += "&Experience=$selectedExperience";
    if (selectedDistance != null) api += "&Distance=$selectedDistance";
    if (userLat != null) api += "&lat=$userLat&lng=$userLng";

    print("📌 API → $api");

    final res = await http.get(Uri.parse(api));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      doctors = data["users"] ?? [];
      filteredDoctors = doctors;

      cities = doctors.map((e) => e["city"]).where((e) => e != null).toSet().toList();

      departments = ["All"];
      departments.addAll((data["allSubDepartments"] ?? []).where((e) => e != null).toList());

      // Apply price filter
      applyPriceFilter();

      setState(() => loading = false);
    } else {
      setState(() => loading = false);
    }
  }

  void applyPriceFilter() {
    filteredDoctors = doctors.where((d) {
      int salary = d["Salary"] ?? 0;
      return salary <= priceValue;
    }).toList();

    _search(searchCtrl.text);
  }

  void resetFilters() {
    setState(() {
      selectedCity = null;
      selectedDepartment = "All";
      selectedExperience = null;
      selectedDistance = null;
      searchCtrl.clear();
      priceValue = 500;
      filteredDoctors = doctors;
    });
  }

  void _search(String query) {
    setState(() {
      filteredDoctors = filteredDoctors.where((d) =>
          d["username"].toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Find Doctors"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
      ),

      body: Column(children: [
        _filterPanel(),
        _searchBox(),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : filteredDoctors.isEmpty
              ? const Center(child: Text("No matching doctors found ❌"))
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredDoctors.length,
            itemBuilder: (_, i) => _doctorCard(filteredDoctors[i]),
          ),
        )
      ]),
    );
  }

  // 🔥 SEARCH BOX
  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: searchCtrl,
        onChanged: _search,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.teal),
          hintText: "Search doctor...",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // 🔥 FILTERS PANEL
  Widget _filterPanel() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(filterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                onPressed: () => setState(() => filterExpanded = !filterExpanded),
              )
            ],
          ),
          if (filterExpanded) ...[
            _dropdown("City", selectedCity, cities, (v) {
              setState(() => selectedCity = v);
              fetchDoctors();
            }),
            SizedBox(height: 10),

            _dropdown("Speciality", selectedDepartment, departments, (v) {
              setState(() => selectedDepartment = v);
              fetchDoctors();
            }),
            SizedBox(height: 10),

            _dropdown("Experience", selectedExperience, ["1+", "3+", "5+", "10+"], (v) {
              setState(() => selectedExperience = v);
              fetchDoctors();
            }),
            SizedBox(height: 10),

            _dropdown("Distance", selectedDistance, ["5 km", "10 km", "20 km", "50 km"], (v) {
              setState(() => selectedDistance = v);
              fetchDoctors();
            }),

            SizedBox(height: 15),

            Text("Consultation Fee (₹${priceValue.toInt()})", style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: priceValue,
              min: 0,
              max: 2000,
              divisions: 20,
              activeColor: Colors.teal,
              onChanged: (v) {
                setState(() {
                  priceValue = v;
                  applyPriceFilter();
                });
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: resetFilters, child: Text("Reset", style: TextStyle(color: Colors.red))),
            ),
          ]
        ]),
      ),
    );
  }
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
        underline: const SizedBox(),

        // Prevent crash when selected value removed
        value: (value != null && items.contains(value)) ? value : null,

        hint: Text(
          "Select $label",
          style: TextStyle(color: Colors.grey.shade600),
        ),

        items: items.map<DropdownMenuItem<String>>((e) {
          return DropdownMenuItem(
            value: e.toString(),
            child: Text(
              e.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),

        onChanged: (val) {
          if (val == "All") {
            onSelect(null);
          } else {
            onSelect(val);
          }
        },
      ),
    );
  }

  Widget _doctorCard(d) {
    final img = d["profile"] != null
        ? "https://hospitalquee.onrender.com/${d["profile"]}"
        : "https://cdn-icons-png.flaticon.com/512/3789/3789820.png";

    final phone = d["phone"] ?? "";

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(img)),
          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d["username"], style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("${d["Experience"] ?? "0"} yrs experience"),
                SizedBox(height: 5),
                Text((d["subDepartments"] as List?)?.join(", ") ?? "Specialist"),
                SizedBox(height: 5),
                Text(
                  "₹ ${d["Salary"] ?? "NA"}",
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailsScreen(
                              doctorId: d["_id"], // <-- FIXED
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: const Text("Book",style: TextStyle(color: Colors.white),),
                    ),

                    const SizedBox(width: 10),

                    OutlinedButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailsScreen(
                              doctorId: d["_id"], // <-- FIXED
                            ),
                          ),
                        );
                      },
                      child: const Text("Call"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
