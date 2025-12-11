import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../../shared/services/api_service.dart';
import '../../models/doctor_detail_model.dart';
import '../appointment/book_appointment_screen.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  DoctorDetailsModel? doctor;
  bool loading = true;

  String? selectedHospitalId;
  List bookedAppointments = [];
  List<Map<String, dynamic>> finalSlots = [];
  DateTime? selectedDate;
  String? selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  // Compare Time
  bool timeMatch(String t1, String t2) {
    final f = DateFormat("hh:mm a");
    final a = f.parse(t1);
    final b = f.parse(t2);
    return a.hour == b.hour && a.minute == b.minute;
  }

  // Fetch Doctor Details
  Future<void> fetchDoctorDetails() async {
    final res = await http.get(Uri.parse(
        "https://hospitalquee.onrender.com/get-vendor/${widget.doctorId}"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)["Mpage"];
      doctor = DoctorDetailsModel.fromJson(data);
      selectedHospitalId = doctor!.headId.first["_id"];

      await fetchBookedAppointments();
      await generateSlots();

      setState(() => loading = false);
    }
  }

  // Fetch Booked Slots
  Future<void> fetchBookedAppointments() async {
    final today = DateTime.now();
    final end = today.add(const Duration(days: 7));

    final url =
        "${ApiService.baseUrl}/admin/all-booking?search=&startDate=${DateFormat('yyyy-MM-dd').format(today)}&endDate=${DateFormat('yyyy-MM-dd').format(end)}&status=&productId=&type=3&userId=$selectedHospitalId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      bookedAppointments = jsonDecode(response.body)["Order"];
    }
  }

  // Generate Slot Logic
  Future<void> generateSlots() async {
    final today = DateTime.now();
    final schedule = doctor!.schedule[selectedHospitalId]!;
    finalSlots.clear();

    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final dayName = DateFormat('EEEE').format(date);

      if (!schedule.containsKey(dayName) || schedule[dayName]["isClosed"] == "true") {
        finalSlots.add({"date": date, "slots": []});
        continue;
      }

      List rawSlots = schedule[dayName]["slots"];
      List slotList = [];

      for (var slot in rawSlots) {
        final slotLabel = "${slot["open"]} - ${slot["close"]}";
        int maxPatients = int.tryParse(slot["patients"] ?? "0") ?? 0;

        int booked = bookedAppointments.where((b) {
          return DateFormat('yyyy-MM-dd').format(DateTime.parse(b["date"])) ==
              DateFormat('yyyy-MM-dd').format(date) &&
              timeMatch(b["Ltime"], slot["open"]);
        }).length;

        int left = maxPatients - booked;
        if (left < 0) left = 0;

        slotList.add({"slot": slotLabel, "left": left});
      }

      finalSlots.add({"date": date, "slots": slotList});
    }

    setState(() {});
  }

  // ------------------------- UI ------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Doctor Details"), backgroundColor: Colors.teal, leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color:Colors.white),
        padding: const EdgeInsets.only(left: 20),
      ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _doctorProfile(),
          const SizedBox(height: 15),
          _infoCard("About Doctor", doctor!.about.replaceAll(RegExp(r'<[^>]*>'), "")),
          const SizedBox(height: 15),
          _infoCard("Specialties", doctor!.subDepartments.join(" • ")),
          const SizedBox(height: 15),
          _educationCard(),
          const SizedBox(height: 15),
          _slotCard(),
          const SizedBox(height: 20),
          _bookButton(),
        ]),
      ),
    );
  }

  // Doctor Profile Card
  Widget _doctorProfile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          CircleAvatar(radius: 55, backgroundImage: NetworkImage(doctor!.profile)),
          const SizedBox(height: 12),
          Text(doctor!.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          Text(doctor!.location, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, children: [
            _chip("${doctor!.experience} yrs Experience"),
            _chip(doctor!.gender),
            _chip("₹${doctor!.salary}")
          ])
        ]),
      ),
    );
  }

  Widget _chip(text) => Chip(
      backgroundColor: Colors.teal.shade50,
      label: Text(text, style: const TextStyle(color: Colors.teal)));

  Widget _infoCard(title, content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(color: Colors.grey.shade700))
        ]),
      ),
    );
  }

  Widget _educationCard() {
    return _infoCard("Education", doctor!.educationList.join("\n"));
  }
  Widget _slotCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Title Row ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Available Slots",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // 🔄 Refresh Button
                IconButton(
                  icon: const Icon(Icons.refresh, size: 26, color: Colors.teal),
                  onPressed: () async {
                    await fetchBookedAppointments();
                    await generateSlots();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Slots refreshed successfully")),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ---------------- Hospital Dropdown ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Hospital", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: selectedHospitalId,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(12),

                    items: doctor!.headId.map<DropdownMenuItem<String>>((hospital) {
                      return DropdownMenuItem<String>(
                        value: hospital["_id"],
                        child: Text(hospital["username"], style: const TextStyle(fontWeight: FontWeight.w500)),
                      );
                    }).toList(),

                    onChanged: (value) async {
                      setState(() {
                        selectedHospitalId = value;
                        selectedDate = null;
                        selectedTimeSlot = null;
                      });

                      await fetchBookedAppointments();
                      await generateSlots();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            Divider(),
            const SizedBox(height: 15),

            // ---------------- Date Selector ----------------
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: finalSlots.length,
                itemBuilder: (_, i) {
                  final d = finalSlots[i];
                  int total = d["slots"].fold(0, (s, e) => s + e["left"]);

                  return GestureDetector(
                    onTap: () => setState(() => selectedDate = d["date"]),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: 100,
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selectedDate == d["date"] ? Colors.teal.shade50 : Colors.white,
                        border: Border.all(
                          color: selectedDate == d["date"] ? Colors.teal : Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('EEE').format(d["date"]), style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(DateFormat('d MMM').format(d["date"])),
                          SizedBox(height: 4),
                          Text("$total slots", style: TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- Time Slots ----------------
            if (selectedDate != null)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: finalSlots
                    .firstWhere((x) => x["date"] == selectedDate)["slots"]
                    .map<Widget>((slot) {
                  return ChoiceChip(
                    label: Text("${slot["slot"]} (${slot["left"]})"),
                    selected: selectedTimeSlot == slot["slot"],
                    selectedColor: Colors.teal,
                    onSelected: slot["left"] == 0 ? null : (_) => setState(() => selectedTimeSlot = slot["slot"]),
                    labelStyle: TextStyle(
                      color: selectedTimeSlot == slot["slot"] ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }


  Widget _bookButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal, minimumSize: Size(double.infinity, 55)),
      onPressed: selectedDate == null || selectedTimeSlot == null
          ? null
          : () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookAppointmentScreen(
            doctorId: doctor!.id,
            doctorName: doctor!.name,
            fee: doctor!.salary ?? 600, selectedTime: '$selectedTimeSlot', selectedDate: '$selectedDate',
          ),
        ),
      ),
      child: const Text("Book Appointment", style: TextStyle(fontSize: 18,color: Colors.white)),
    );
  }
}
