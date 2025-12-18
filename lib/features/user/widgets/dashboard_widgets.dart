import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../views/appointment/appoinment_detials.dart';
import '../views/dashboard_screen.dart' hide kTeal, kTealDark;




// *********************************************************
// ************** REUSABLE SHIMMER WIDGET ******************
// *********************************************************

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(children: [
          Container(height: 140, color: Colors.white),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Container(height: 100, color: Colors.white)),
            const SizedBox(width: 10),
            Expanded(child: Container(height: 100, color: Colors.white)),
            const SizedBox(width: 10),
            Expanded(child: Container(height: 100, color: Colors.white)),
          ]),
        ]),
      ),
    );
  }
}

// *********************************************************
// ************** REUSABLE SLIVER APPBAR *******************
// *********************************************************

class DashboardAppBar extends StatelessWidget {
  final bool isCollapsed;
  final Widget expandedBar;
  final Widget collapsedBar;

  const DashboardAppBar({
    super.key,
    required this.isCollapsed,
    required this.expandedBar,
    required this.collapsedBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [kTeal, kTealDark]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        centerTitle: false,
        title: isCollapsed ? collapsedBar : null,
        background: expandedBar,
      ),
    );
  }
}



/// ------------------- Common Search Bar --------------------
class DashboardSearchBar extends StatelessWidget {
  final bool isCollapsed;
  final String hint;
  final VoidCallback onTap;
  const DashboardSearchBar(
      {super.key,
        required this.isCollapsed,
        required this.hint,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCollapsed ? 38 : 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        Icon(Icons.search, color: kTealDark, size: isCollapsed ? 18 : 22),
        const SizedBox(width: 6),
        Expanded(
          child: TextField(
            readOnly: true,
            onTap: onTap,
            cursorColor: kTealDark,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: isCollapsed ? 12 : 14,
              ),
            ),
          ),
        )
      ]),
    );
  }
}

/// ------------------- Drawer Profile --------------------
class DashboardDrawer extends StatelessWidget {
  final Widget drawerContent;
  const DashboardDrawer({super.key, required this.drawerContent});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.80,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [kTealDark, kTeal]),
        ),
        child: SafeArea(child: drawerContent),
      ),
    );
  }
}

/// ---------------- Drawer Tile Reusable ------------------
class DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const DrawerTile({super.key, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }
}

/// ----------------- Big Card ------------------
class BigCard extends StatelessWidget {
  final String title, sub, image;
  const BigCard({super.key, required this.title, required this.sub, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(15),
      decoration: boxWhite(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: CircleAvatar(
            backgroundColor: kTealLight.withOpacity(0.25),
            radius: 28,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(image),
            ),
          ),
        ),
      ]),
    );
  }
}

/// ----------------- Small Card ------------------
class SmallCard extends StatelessWidget {
  final String title, image;
  const SmallCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 90,
        width: 90,
        decoration: boxWhite(),
        child: Center(
          child: CircleAvatar(
            backgroundColor: Colors.orange.shade100,
            radius: 28,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(image),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }
}

/// ---------------- Promo Section ----------------
class PromoSurgeries extends StatelessWidget {
  const PromoSurgeries({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [kTeal.withOpacity(0.15), Colors.white]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Affordable Surgeries by Expert Surgeons",
            style: TextStyle(fontWeight: FontWeight.bold, color: kTeal)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          PromoIcon("Piles", "https://cdn-icons-png.flaticon.com/512/2299/2299095.png"),
          PromoIcon("Hernia", "https://cdn-icons-png.flaticon.com/512/4149/4149677.png"),
          PromoIcon("Kidney", "https://cdn-icons-png.flaticon.com/512/4149/4149706.png"),
          PromoIcon("More", "https://cdn-icons-png.flaticon.com/512/565/565655.png", isMore: true),
        ]),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: kTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Get Cost Estimate"),
        )
      ]),
    );
  }
}

class PromoIcon extends StatelessWidget {
  final String label, image;
  final bool isMore;
  const PromoIcon(this.label, this.image, {super.key, this.isMore = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(
        backgroundColor: isMore ? Colors.white : Colors.orange.shade50,
        radius: 28,
        child: Padding(padding: const EdgeInsets.all(6), child: Image.network(image)),
      ),
      const SizedBox(height: 8),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
    ]);
  }
}

/// ---------------- Doctor Grid ---------------
class DoctorGrid extends StatelessWidget {
  final List categories;
  const DoctorGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 20),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final doc = categories[i];
        return Column(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: doc["bg"].withOpacity(0.18), borderRadius: BorderRadius.circular(15)),
            child: Image.network(doc["image"], height: 38),
          ),
          const SizedBox(height: 6),
          Text(doc["name"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
        ]);
      },
    );
  }
}

/// ---------------- BEST Offers ----------------
class BestOffersSection extends StatelessWidget {
  const BestOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration:
      BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF101B3F), Color(0xFF071026)]), borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.percent, color: Colors.white),
          SizedBox(width: 8),
          Text("Best Offers", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height: 6),
        const Text("Explore deals, offers, health updates and more", style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 15),
        SizedBox(
          height: 180,
          child: ListView(scrollDirection: Axis.horizontal, children: const [
            OfferCard("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
            OfferCard("https://cdn-icons-png.flaticon.com/512/2966/2966401.png"),
            OfferCard("https://cdn-icons-png.flaticon.com/512/2966/2966480.png"),
          ]),
        )
      ]),
    );
  }
}

class OfferCard extends StatelessWidget {
  final String img;
  const OfferCard(this.img, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(img, fit: BoxFit.cover)),
    );
  }
}
// /// ---------------- AI Bottom Bar ----------------
// class CareAIBar extends StatelessWidget {
//   final VoidCallback onTap;
//   const CareAIBar({super.key, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(30),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(30),
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//           decoration: BoxDecoration(
//             color: kTealDark,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.18),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               )
//             ],
//           ),
//           child: Row(
//             children: const [
//               CircleAvatar(
//                 radius: 16,
//                 backgroundImage: NetworkImage(
//                   "https://cdn-icons-png.flaticon.com/512/4712/4712027.png",
//                 ),
//               ),
//               SizedBox(width: 10),
//               Text(
//                 "Ask Care AI",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Spacer(),
//               Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

/// ---- Box Shadow Common ----
BoxDecoration boxWhite() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 5))],
);
