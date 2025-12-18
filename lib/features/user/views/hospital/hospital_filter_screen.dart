import 'dart:convert';
import 'package:appointment_app/features/hospital/services/hospital_api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/user_api_service.dart';
import 'hospital_doctor_screen.dart';

class HospitalFilterScreen extends StatefulWidget {
  const HospitalFilterScreen({super.key});

  @override
  State<HospitalFilterScreen> createState() => _HospitalFilterScreenState();
}

class _HospitalFilterScreenState extends State<HospitalFilterScreen> {
  List hospitals = [];
  List filteredHospitals = []; // For search
  bool loading = true;
  bool fetchingLocation = false;

  String? selectedDepartment = "All";
  String? selectedDistance;
  String? selectedExperience;
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
    searchController.addListener(_onSearchChanged);
    _initializeData();
  }

  @override
  void dispose() {
    placesController.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = searchController.text.toLowerCase();
      filteredHospitals = hospitals.where((h) {
        final name = (h["username"] ?? "").toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _initializeData() async {
    await _getCurrentLocation(showLoading: false);
    await fetchHospitals();
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
        _showSnackBar("Please enable location services in settings");
        if (showLoading) setState(() => fetchingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showSnackBar("Location permission is required");
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

  Future<void> fetchHospitals() async {
    setState(() {
      loading = true;
      hospitals = [];
      filteredHospitals = [];
    });

    String api = "${ApiService.baseUrl}/all-hospital?page=1&limit=50";

    if (filterState != null && filterState!.isNotEmpty) api += "&state=${Uri.encodeComponent(filterState!)}";
    if (filterCity != null && filterCity!.isNotEmpty) api += "&city=${Uri.encodeComponent(filterCity!)}";
    if (filterPosition != null) api += "&lat=${filterPosition!.latitude}&lng=${filterPosition!.longitude}";
    if (selectedDepartment != null && selectedDepartment != "All") api += "&department=${Uri.encodeComponent(selectedDepartment!)}";
    if (selectedDistance != null) {
      String dist = selectedDistance!.replaceAll(" km", "").trim();
      api += "&Distance=$dist";
    }
    if (selectedExperience != null) api += "&Experience=$selectedExperience";
    if (selectedConsultation != null) api += "&Consultation=$selectedConsultation";

    print('API URL: $api');

    try {
      final response = await http.get(Uri.parse(api));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List rawHospitals = data["users"] ?? [];

        setState(() {
          hospitals = rawHospitals.map((h) {
            double? lat = double.tryParse(h["lat"]?.toString() ?? "");
            double? lng = double.tryParse(h["lng"]?.toString() ?? "");
            return {
              ...h,
              "distance": (lat != null && lng != null) ? calculateDistance(lat, lng).toStringAsFixed(1) : "--"
            };
          }).toList();

          if (filterPosition != null && hospitals.isNotEmpty) {
            hospitals.sort((a, b) {
              double distA = double.tryParse(a["distance"] ?? "999") ?? 999;
              double distB = double.tryParse(b["distance"] ?? "999") ?? 999;
              return distA.compareTo(distB);
            });
          }

          filteredHospitals = List.from(hospitals); // Initial copy for search
          departments = ["All", ...(data["allSubDepartments"] ?? [])];

          // Apply current search query if any
          _onSearchChanged();
        });
      }
    } catch (e) {
      print("API Error: $e");
      _showSnackBar("Failed to load hospitals");
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
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              child: Column(
                children: [
                  Container(margin: EdgeInsets.only(top: 16), width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
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
                              selectedDistance = null;
                              selectedExperience = null;
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
                          _buildSectionTitle("Department"),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedDepartment,
                            decoration: _filterInputDecoration("All Departments"),
                            items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d == "All" ? "All Departments" : d))).toList(),
                            onChanged: (v) { setState(() => selectedDepartment = v); sheetSetState(() {}); },
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
                          _buildSectionTitle("Minimum Experience"),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedExperience,
                            hint: const Text("Any"),
                            decoration: _filterInputDecoration("Any"),
                            items: ["5", "10", "15", "20"].map((e) => DropdownMenuItem(value: e, child: Text("$e+ years"))).toList(),
                            onChanged: (v) { setState(() => selectedExperience = v); sheetSetState(() {}); },
                          ),
                          const SizedBox(height: 28),
                          _buildSectionTitle("Max Consultation Fee"),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedConsultation,
                            hint: const Text("Any"),
                            decoration: _filterInputDecoration("Any"),
                            items: ["500", "1000", "1500", "2000"].map((e) => DropdownMenuItem(value: e, child: Text("< ₹$e"))).toList(),
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
                          await fetchHospitals();
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
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
        backgroundColor: Colors.teal,
        title: const Text("Find Hospitals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
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
      body: SafeArea(
        child: Column(
          children: [
            // Location Bar
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search hospital by name...",
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),

            // Hospital List
            Expanded(
              child: loading
                  ? ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 8,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => const HospitalCardShimmer(),
              )
                  : filteredHospitals.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 90, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    const Text("No hospitals found", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("Try adjusting filters or search", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredHospitals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _hospitalCard(filteredHospitals[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hospitalCard(Map h) {
    final List subDepts = h["subDepartments"] ?? [];
    final List stats = h["stats"] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 18, offset: const Offset(0, 10))]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    h["profile"] != null ? "https://hospitalquee.onrender.com/${h["profile"]}" : "https://cdn-icons-png.flaticon.com/512/3103/3103472.png",
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.local_hospital, size: 40)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(h["username"] ?? "Hospital", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                          if (h["verified"] == 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                              child: const Text("VERIFIED", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(h["city"] ?? "", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text("${h["distance"]} km away", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.teal)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((h["about"] ?? "").toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_stripHtml(h["about"]), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, color: Colors.grey[700])),
            ],
            if (subDepts.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 6, children: subDepts.take(4).map<Widget>((e) => _chip(e)).toList()),
            ],
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: stats.take(4).map<Widget>((s) => Column(children: [Text(s["value"], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(s["label"], style: TextStyle(fontSize: 12, color: Colors.grey[600]))])).toList()),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text("Call"),
                    onPressed: () async {
                      if (h["phone"] != null) await launchUrl(Uri(scheme: "tel", path: h["phone"]));
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.teal, side: const BorderSide(color: Colors.teal), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HospitalDoctorsScreen(hospitalId: h["_id"]))),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text("View Doctors", style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[800])),
    );
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

class HospitalCardShimmer extends StatelessWidget {
  const HospitalCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 24, color: Colors.white),
                    const SizedBox(height: 12),
                    Container(width: 180, height: 18, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 16, color: Colors.white),
                    const SizedBox(height: 24),
                    Row(children: [Expanded(child: Container(height: 54, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Container(height: 54, color: Colors.white))]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}