import 'package:flutter/material.dart';
import 'category_screen.dart';
import 'doctor/doctor_screen.dart';
import 'hospital/hospital_screen.dart';

// ===================== COLORS =====================
const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class SearchItem {
  final String name;
  final String image;
  final String type; // Doctor | Hospital | Category
  final String desc;

  SearchItem({
    required this.name,
    required this.image,
    required this.type,
    required this.desc,
  });
}

// ===================== DUMMY DATA =====================
List<SearchItem> searchList = [
  // Doctors
  SearchItem(
    name: "Cardiologist",
    image: "https://cdn-icons-png.flaticon.com/512/3004/3004458.png",
    type: "Doctor",
    desc: "Heart specialist",
  ),
  SearchItem(
    name: "Physician",
    image: "https://cdn-icons-png.flaticon.com/512/3048/3048127.png",
    type: "Doctor",
    desc: "General checkups",
  ),
  SearchItem(
    name: "Dermatologist",
    image: "https://cdn-icons-png.flaticon.com/512/9840/9840665.png",
    type: "Doctor",
    desc: "Skin & Hair doctor",
  ),
  SearchItem(
    name: "Pediatrician",
    image: "https://cdn-icons-png.flaticon.com/512/4140/4140047.png",
    type: "Doctor",
    desc: "Child specialist",
  ),

  // Hospitals
  SearchItem(
    name: "Fortis Hospital",
    image: "https://cdn-icons-png.flaticon.com/512/2966/2966327.png",
    type: "Hospital",
    desc: "Noida Sector 63",
  ),
  SearchItem(
    name: "Apollo Hospital",
    image: "https://cdn-icons-png.flaticon.com/512/2966/2966327.png",
    type: "Hospital",
    desc: "Delhi Multi-speciality",
  ),
  SearchItem(
    name: "Max Super Speciality",
    image: "https://cdn-icons-png.flaticon.com/512/2966/2966327.png",
    type: "Hospital",
    desc: "Saket • Cardiac care",
  ),

  // Category
  SearchItem(
    name: "Orthopaedic",
    image: "https://cdn-icons-png.flaticon.com/512/4508/4508315.png",
    type: "Category",
    desc: "Bone & joint problems",
  ),
  SearchItem(
    name: "Gynecology",
    image: "https://cdn-icons-png.flaticon.com/512/9429/9429620.png",
    type: "Category",
    desc: "Women's health",
  ),
  SearchItem(
    name: "Neurology",
    image: "https://cdn-icons-png.flaticon.com/512/2180/2180655.png",
    type: "Category",
    desc: "Brain & nerves doctor",
  ),
];

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});
  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  TextEditingController searchCtrl = TextEditingController();
  List<SearchItem> filtered = [];

  bool isSearching = false;

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filtered = [];
      } else {
        filtered = searchList
            .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kTeal,
        title: const Text(
          "Search",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _searchBox(),
          Expanded(child: _bodyResults()),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: searchCtrl,
        cursorColor: kTealDark,
        onChanged: filterSearch,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: kTealDark),
          hintText: "Search doctors, hospitals, specialties...",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: kTeal.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kTealDark, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _bodyResults() {
    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "🔍 Search to view results",
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        SearchItem item = filtered[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.teal.shade50,
            child: Image.network(item.image, height: 32),
          ),
          title: Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(item.desc, style: const TextStyle(fontSize: 12)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.type,
              style: const TextStyle(fontSize: 11, color: kTealDark),
            ),
          ),
          onTap: () {
            if (item.type == "Doctor") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorDetailScreen(data: item),
                ),
              );
            } else if (item.type == "Hospital") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HospitalDetailScreen(data: item),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryDetailScreen(data: item),
                ),
              );
            }
          },
        );
      },
    );
  }
}
