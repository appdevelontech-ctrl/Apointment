import 'package:flutter/material.dart';

const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class LabtestScreen extends StatelessWidget {
  const LabtestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),

      appBar: AppBar(

        title: const Text("Lab Tests",style: TextStyle(fontWeight: FontWeight.w600,color: kTealDark)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // 🔍 SEARCH BAR
          _searchBar(),

          const SizedBox(height: 20),

          const Text("Popular Lab Tests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _testCard(context, title: "Complete Blood Count (CBC)", price: "₹349", time: "Reports in 12 hrs"),
          _testCard(context, title: "Thyroid Profile (TSH, T3, T4)", price: "₹599", time: "Reports in 24 hrs"),
          _testCard(context, title: "Vitamin D Test", price: "₹899", time: "Reports in 2 days"),

          const SizedBox(height: 20),

          const Text("Packages & Health Checks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _packageCard(context, title: "Full Body Checkup", tests: "Includes 60+ tests", price: "₹1999"),
          _packageCard(context, title: "Diabetes Profile", tests: "Includes 10+ tests", price: "₹1099"),
          _packageCard(context, title: "Heart Health Package", tests: "Includes 25+ tests", price: "₹2499"),
        ]),
      ),
    );
  }

  // ===================== WIDGETS =====================

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search tests (CBC, Thyroid, Vitamin D...)",
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}

// ===================== TEST CARD =====================

Widget _testCard(BuildContext context, {required String title, required String price, required String time}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kTeal.withOpacity(0.20)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 4))],
    ),
    child: Row(children: [

      // 🧪 Icon
      Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(color: kTeal.withOpacity(0.09), shape: BoxShape.circle),
        child: const Icon(Icons.biotech_rounded, color: kTealDark),
      ),
      const SizedBox(width: 12),

      // ➤ Info
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 6),
          Row(children: const [
            Icon(Icons.home_filled, size: 13, color: kTealDark),
            SizedBox(width: 4),
            Text("Home Sample Collection", style: TextStyle(fontSize: 11, color: kTealDark)),
          ]),
        ]),
      ),

      // ₹ Price + Book Btn
      Column(
        children: [
          Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTealDark)),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _openBooking(context, title, price),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: kTeal)),
              child: const Text("Book", style: TextStyle(fontSize: 12, color: kTeal)),
            ),
          )
        ],
      ),
    ]),
  );
}

// ===================== PACKAGE CARD =====================

Widget _packageCard(BuildContext context, {required String title, required String tests, required String price}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kTeal.withOpacity(0.20)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 4))],
    ),
    child: Row(children: [

      Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(color: kTeal.withOpacity(0.09), shape: BoxShape.circle),
        child: const Icon(Icons.health_and_safety, color: kTealDark),
      ),
      const SizedBox(width: 12),

      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          Text(tests, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 5),
          Row(children: const [
            Icon(Icons.verified_rounded, size: 14, color: Colors.green),
            SizedBox(width: 4),
            Text("NABL Certified", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),

      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTealDark)),
        const SizedBox(height: 4),
        const Text("Starts from", style: TextStyle(color: Colors.grey, fontSize: 10)),
      ]),
    ]),
  );
}

// ===================== BOOKING POPUP =====================

void _openBooking(BuildContext context, String name, String price) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTealDark)),
          const SizedBox(height: 8),
          Text("Price: $price", style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          const Text("✔ Home Collection Available\n✔ NABL Certified Labs\n✔ Free Report Consultation",
              style: TextStyle(fontSize: 12, height: 1.4)),
          const SizedBox(height: 18),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kTeal, minimumSize: const Size(double.infinity, 50)),
            onPressed: () => Navigator.pop(context),
            child: const Text("Proceed to Book", style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    },
  );
}
