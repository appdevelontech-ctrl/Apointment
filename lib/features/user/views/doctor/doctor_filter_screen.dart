import 'dart:convert';
import 'package:appointment_app/features/user/views/doctor/doctor_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/services/api_service.dart';
import 'doctor_detial_screen.dart';
import '../../services/user_api_service.dart';

class DoctorFilterScreen extends StatefulWidget {
  const DoctorFilterScreen({super.key});

  @override
  State<DoctorFilterScreen> createState() => _DoctorFilterScreenState();
}

class _DoctorFilterScreenState extends State<DoctorFilterScreen> {
  List doctors = [];
  List filteredDoctors = []; // ← this makes search work
  bool loading = true;
  bool fetchingLocation = false;

  String? selectedDepartment = "All";
  String? selectedExperience;
  String? selectedDistance;
  String? selectedConsultation;

  List<String> departments = ["All"];

  Position? filterPosition;
  String? filterState;
  String? filterCity;
  String locationDisplay = "Detecting location...";

  late TextEditingController placesController;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    placesController = TextEditingController();
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged); // ← this makes search live
    _initializeData();
  }

  @override
  void dispose() {
    placesController.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  // Search works perfectly now
  void _onSearchChanged() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredDoctors = List.from(doctors);
      } else {
        filteredDoctors = doctors.where((doctor) {
          final name = (doctor["username"] ?? "").toLowerCase();
          final speciality = (doctor["subDepartments"] as List?)?.join(" ").toLowerCase() ?? "";
          return name.contains(query) || speciality.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _initializeData() async {
    await _getCurrentLocation(showLoading: false);
    await fetchDoctors();
  }

  Future<void> _getCurrentLocation({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        fetchingLocation = true;
        locationDisplay = "Fetching your location...";
      });
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar("Please enable location services");
        if (showLoading) setState(() => fetchingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showSnackBar("Location permission required");
        if (showLoading) setState(() => fetchingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      String? city, state;
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        city = place.locality ?? place.subAdministrativeArea ?? '';
        state = place.administrativeArea ?? '';
      }

      setState(() {
        filterPosition = position;
        filterCity = city;
        filterState = state;
        locationDisplay = "Current Location";
        placesController.clear();
        fetchingLocation = false;
      });

      if (showLoading) _showSnackBar("Location updated successfully!");
    } catch (e) {
      if (showLoading) {
        setState(() {
          fetchingLocation = false;
          locationDisplay = "Failed to get location";
        });
        _showSnackBar("Could not fetch location");
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.teal[800], behavior: SnackBarBehavior.floating),
      );
    }
  }

  double calculateDistance(double lat, double lng) {
    if (filterPosition == null) return 99999;
    return Geolocator.distanceBetween(filterPosition!.latitude, filterPosition!.longitude, lat, lng) / 1000;
  }

  Future<void> fetchDoctors() async {
    setState(() {
      loading = true;
      doctors = [];
      filteredDoctors = [];
    });

    String api = "${ApiService.baseUrl}/all-vendors?page=1&limit=50";

    if (filterState != null && filterState!.isNotEmpty) api += "&state=${Uri.encodeComponent(filterState!)}";
    if (filterCity != null && filterCity!.isNotEmpty) api += "&city=${Uri.encodeComponent(filterCity!)}";
    if (filterPosition != null) api += "&lat=${filterPosition!.latitude}&lng=${filterPosition!.longitude}";
    if (selectedDepartment != null && selectedDepartment != "All") api += "&department=${Uri.encodeComponent(selectedDepartment!)}";
    if (selectedExperience != null) api += "&Experience=$selectedExperience";
    if (selectedDistance != null) {
      String dist = selectedDistance!.replaceAll(" km", "").trim();
      api += "&Distance=$dist";
    }
    if (selectedConsultation != null) api += "&Consultation=$selectedConsultation";

    print("API URL: $api");

    try {
      final response = await http.get(Uri.parse(api));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List rawDoctors = data["users"] ?? [];

        setState(() {
          doctors = rawDoctors.map((d) {
            double? lat = d["lat"] != null ? double.tryParse(d["lat"].toString()) : null;
            double? lng = d["lng"] != null ? double.tryParse(d["lng"].toString()) : null;
            return {
              ...d,
              "distance": (lat != null && lng != null) ? calculateDistance(lat, lng).toStringAsFixed(1) : "--"
            };
          }).toList();

          if (filterPosition != null && doctors.isNotEmpty) {
            doctors.sort((a, b) {
              double distA = double.tryParse(a["distance"] ?? "999") ?? 999;
              double distB = double.tryParse(b["distance"] ?? "999") ?? 999;
              return distA.compareTo(distB);
            });
          }

          filteredDoctors = List.from(doctors); // copy for search
          departments = ["All", ...(data["allSubDepartments"] ?? [])];

          // apply current search again after new data comes
          _onSearchChanged();
        });
      }
    } catch (e) {
      _showSnackBar("Failed to load doctors");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<bool?> showFilterBottomSheet() async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => StatefulBuilder(
        builder: (context, sheetSetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.88,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            snap: true,
            snapSizes: const [0.6, 0.88],
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              child: Column(
                children: [
                  Container(margin: const EdgeInsets.only(top: 16), width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Filters", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              selectedDepartment = "All";
                              selectedExperience = null;
                              selectedDistance = null;
                              selectedConsultation = null;
                              placesController.clear();
                            });
                            await _getCurrentLocation(showLoading: true);
                            sheetSetState(() {});
                          },
                          child: const Text("Reset", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Location"),
                          const SizedBox(height: 12),
                          GooglePlaceAutoCompleteTextField(
                            textEditingController: placesController,
                            googleAPIKey: UserApiService.googlePlacesKey,
                            inputDecoration: InputDecoration(
                              hintText: "Search city, area or place...",
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: placesController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => placesController.clear()) : null,
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            ),
                            debounceTime: 600,
                            countries: ["in"],
                            isLatLngRequired: true,
                            getPlaceDetailWithLatLng: (prediction) async {
                              if (prediction.lat != null && prediction.lng != null) {
                                double lat = double.parse(prediction.lat!);
                                double lng = double.parse(prediction.lng!);
                                List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
                                String? city = placemarks.isNotEmpty ? (placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? '') : '';
                                String? state = placemarks.isNotEmpty ? placemarks.first.administrativeArea ?? '' : '';
                                setState(() {
                                  filterPosition = Position(latitude: lat, longitude: lng, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0.0, headingAccuracy: 0.0);
                                  filterCity = city;
                                  filterState = state;
                                  locationDisplay = prediction.description ?? "Selected Location";
                                  placesController.text = prediction.description ?? "";
                                });
                              }
                            },
                            itemClick: (p) => placesController.text = p.description ?? "",
                            itemBuilder: (_, __, p) => ListTile(leading: const Icon(Icons.location_on_outlined), title: Text(p.description ?? "")),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: fetchingLocation ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.my_location_rounded, size: 22),
                              label: Text(fetchingLocation ? "Fetching..." : "Use Current Location", style: const TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 6),
                              onPressed: fetchingLocation ? null : () async {
                                await _getCurrentLocation(showLoading: true);
                                placesController.clear();
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionTitle("Speciality"),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedDepartment,
                            decoration: _filterInputDecoration("All Specialities"),
                            items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d == "All" ? "All Specialities" : d))).toList(),
                            onChanged: (v) { setState(() => selectedDepartment = v); sheetSetState(() {}); },
                          ),
                          const SizedBox(height: 28),
                          _buildSectionTitle("Minimum Experience"),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedExperience,
                            hint: const Text("Any experience"),
                            decoration: _filterInputDecoration("Any experience"),
                            items: ["5", "10", "15", "20"].map((e) => DropdownMenuItem(value: e, child: Text("$e+ years"))).toList(),
                            onChanged: (v) { setState(() => selectedExperience = v); sheetSetState(() {}); },
                          ),
                          const SizedBox(height: 28),
                          _buildSectionTitle("Maximum Distance"),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedDistance,
                            hint: const Text("No limit"),
                            decoration: _filterInputDecoration("No limit"),
                            items: ["5 km", "10 km", "20 km", "50 km"].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) { setState(() => selectedDistance = v); sheetSetState(() {}); },
                          ),
                          const SizedBox(height: 28),
                          _buildSectionTitle("Max Consultation Fee"),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedConsultation,
                            hint: const Text("Any fee"),
                            decoration: _filterInputDecoration("Any fee"),
                            items: ["500", "1000", "1500", "2000"].map((e) => DropdownMenuItem(value: e, child: Text("Under ₹$e"))).toList(),
                            onChanged: (v) { setState(() => selectedConsultation = v); sheetSetState(() {}); },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))]),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 8),
                        onPressed: () async {
                          await fetchDoctors();
                          if (mounted) Navigator.pop(context, true);
                        },
                        child: const Text("Apply Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  InputDecoration _filterInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.teal, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Find Doctors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () async {
              final applied = await showFilterBottomSheet();
              if (applied == true) setState(() {});
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: Colors.teal.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.teal[700], size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(locationDisplay, style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search doctor by name or speciality...",
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => const DoctorCardShimmer(),
            )
                : filteredDoctors.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 90, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text("No doctors found", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text("Try adjusting filters or search", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDoctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _doctorCard(filteredDoctors[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorCard(Map d) {
    final profile = d["profile"] != null ? "https://hospitalquee.onrender.com/${d["profile"]}" : "https://cdn-icons-png.flaticon.com/512/3789/3789820.png";
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 42, backgroundImage: NetworkImage(profile), backgroundColor: Colors.grey[200]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d["username"]?.toString().trim() ?? "Doctor", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text("${d["Experience"] ?? 0} years experience", style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text((d["subDepartments"] as List?)?.join(", ") ?? "General Practitioner", style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 6),
                Text("₹${d["Salary"] ?? "NA"}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal)),
                if (d["distance"] != "--") ...[
                  const SizedBox(height: 4),
                  Text("${d["distance"]} km away", style: TextStyle(color: Colors.teal[600], fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctorId: d["_id"]))),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text("Book", style: TextStyle(fontWeight: FontWeight.bold,color:  Colors.white)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => launchUrl(Uri(scheme: "tel", path: d["phone"] ?? "")),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.teal), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text("Call", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DoctorCardShimmer extends StatelessWidget {
  const DoctorCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const CircleAvatar(radius: 42, backgroundColor: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(5, (_) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Container(height: 16, color: Colors.white, width: double.infinity))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}