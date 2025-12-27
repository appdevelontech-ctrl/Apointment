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

      appBar: AppBar(
        title: const Text(
          "Doctor Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          padding: const EdgeInsets.only(left: 20),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        // 🔥 bottom extra space for floating button
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            _doctorProfile(),
            const SizedBox(height: 15),

            // 🔥 SLOT CARD JUST AFTER PROFILE
            _slotCard(),

            const SizedBox(height: 15),
            _aboutDoctorCard(),
            const SizedBox(height: 15),
            _specialtiesCard(),
            const SizedBox(height: 15),
            _educationCard(),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: isSlotSelectedAndAvailable
            ? _floatingBookButton()
            : const SizedBox.shrink(),
      ),

      );
  }

  bool get isSlotSelectedAndAvailable {
    if (selectedDate == null || selectedTimeSlot == null) return false;

    final slotsForDate =
    finalSlots.firstWhere((x) => x["date"] == selectedDate)["slots"];

    final selectedSlot = slotsForDate.firstWhere(
          (s) => s["slot"] == selectedTimeSlot,
      orElse: () => null,
    );

    if (selectedSlot == null) return false;

    return selectedSlot["left"] > 0;
  }


  Widget _floatingBookButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          if (!isSlotSelectedAndAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please select an available time slot"),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookAppointmentScreen(
                doctorId: doctor!.id,
                doctorName: doctor!.name,
                fee: doctor!.salary ?? 600,
                selectedTime: selectedTimeSlot!, // "10:00 AM - 06:00 PM"
                selectedDate: DateFormat('yyyy-MM-dd').format(selectedDate!), // "2025-12-12"
                 selectedHospitalId: '$selectedHospitalId', // 🔥 ADD THIS
              ),
            ),
          );



        },

        child: const Text(
          "Book Appointment",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


  Widget _aboutDoctorCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                "About Doctor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            doctor!.about.replaceAll(RegExp(r'<[^>]*>'), ""),
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
  Widget _specialtiesCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.medical_services_outlined, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                "Specialties",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: doctor!.subDepartments.map((speciality) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  speciality,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget _educationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.school_outlined, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                "Education",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Column(
            children: doctor!.educationList.map((edu) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Dot
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Education Text
                    Expanded(
                      child: Text(
                        edu,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }



  Widget _doctorProfile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(doctor!.profile),
          ),

          const SizedBox(height: 14),

          // Name
          Text(
            doctor!.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          // Location
          Text(
            doctor!.location,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 16),

          // Stats Row (iOS style)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _profileStat("${doctor!.experience}+", "Years"),
              _profileStat("₹${doctor!.salary}", "Fee"),
              _profileStat(doctor!.gender, "Gender"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }



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
  Widget _iosInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }


  Widget _slotCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Available Slots",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.teal),
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

          const SizedBox(height: 14),

          // ================= HOSPITAL SELECT =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedHospitalId,
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: doctor!.headId.map<DropdownMenuItem<String>>((hospital) {
                  return DropdownMenuItem<String>(
                    value: hospital["_id"],
                    child: Text(
                      hospital["username"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
          ),

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ================= DATE SELECT =================
          SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: finalSlots.length,
              itemBuilder: (_, i) {
                final d = finalSlots[i];
                int total = d["slots"].fold(0, (s, e) => s + e["left"]);

                final isSelected = selectedDate == d["date"];

                return GestureDetector(
                  onTap: () => setState(() => selectedDate = d["date"]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 92,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.teal : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(d["date"]),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('d MMM').format(d["date"]),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$total slots",
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ================= TIME SLOTS =================
          if (selectedDate != null)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: finalSlots
                  .firstWhere((x) => x["date"] == selectedDate)["slots"]
                  .map<Widget>((slot) {
                final isSelected = selectedTimeSlot == slot["slot"];
                final isDisabled = slot["left"] == 0;

                return ChoiceChip(
                  label: Text("${slot["slot"]} (${slot["left"]})"),
                  selected: isSelected,
                  selectedColor: Colors.teal,
                  disabledColor: Colors.grey.shade200,
                  onSelected:
                  isDisabled ? null : (_) => setState(() => selectedTimeSlot = slot["slot"]),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                        ? Colors.grey
                        : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }


}
