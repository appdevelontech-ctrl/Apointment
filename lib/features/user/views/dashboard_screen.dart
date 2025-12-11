import 'package:appointment_app/features/user/views/profile_screen.dart';
import 'package:appointment_app/features/user/views/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:shimmer/shimmer.dart';
import '../../../shared/utils/preferences.dart';
import '../controllers/home_controller.dart';
import '../controllers/home_header_controller.dart';
import '../providers/navigation_provider.dart';
import '../widgets/dashboard_widgets.dart';
import 'package:provider/provider.dart';
import 'appointment/appoinments.dart';
import 'careChat_screen.dart';
import 'doctor/doctor_detial_screen.dart';
import 'doctor/doctor_filter_screen.dart';
import 'hospital/hospital_detail_screen.dart';
import 'hospital/hospital_filter_screen.dart';
import 'labtest_screen.dart';
import 'lcoation_picker.dart';
import 'medical_records.dart';


const Color kTeal = Color(0xFF43B1A9);
const Color kTealDark = Color(0xFF0E5E59);
const Color kTealLight = Color(0xFF43B1A9);



class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});
  @override
  State<UserDashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<UserDashboardScreen> {
  String fullText = "Search for medicines, doctors...";
  String animatedText = "";
  int textIndex = 0;
  bool isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeController>(context, listen: false).loadHomeData();
    });

    typeWriter();
    _loadData();
    _loadUser();
    Future.microtask(
      () => Provider.of<HomeHeaderController>(
        context,
        listen: false,
      ).loadHeaders(),
    );
  }

  void _loadUser() async {
    userData = await PrefUtils.getUserData();
    setState(() {});
  }

  void typeWriter() async {
    if (textIndex < fullText.length) {
      setState(() => animatedText += fullText[textIndex]);
      textIndex++;
      Future.delayed(const Duration(milliseconds: 100), typeWriter);
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          animatedText = "";
          textIndex = 0;
        });
        typeWriter();
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);
  }

  Future<void> _onRefresh() async => _loadData();

  final List<Map<String, dynamic>> doctorCategories = [
    {
      "name": "General\nPhysician",
      "image": "https://cdn-icons-png.flaticon.com/512/2966/2966480.png",
      "bg": Colors.blueAccent,
    },
    {
      "name": "Skin & Hair",
      "image": "https://cdn-icons-png.flaticon.com/512/9840/9840665.png",
      "bg": Colors.purple,
    },
    {
      "name": "Women's\nHealth",
      "image": "https://cdn-icons-png.flaticon.com/512/9429/9429620.png",
      "bg": Colors.pink,
    },
    {
      "name": "Dental Care",
      "image": "https://cdn-icons-png.flaticon.com/512/11396/11396941.png",
      "bg": Colors.red,
    },
    {
      "name": "Child\nSpecialist",
      "image": "https://cdn-icons-png.flaticon.com/512/3048/3048127.png",
      "bg": Colors.orange,
    },
    {
      "name": "ENT",
      "image": "https://cdn-icons-png.flaticon.com/512/9440/9440263.png",
      "bg": Colors.blueGrey,
    },
    {
      "name": "Mental\nWellness",
      "image": "https://cdn-icons-png.flaticon.com/512/3297/3297973.png",
      "bg": Colors.teal,
    },
    {
      "name": "More",
      "image": "https://cdn-icons-png.flaticon.com/512/565/565655.png",
      "bg": Colors.grey,
    },
  ];

  final Map<String, String> pngIcons = {
    "hospital": "https://cdn-icons-png.flaticon.com/512/2966/2966327.png",
    "video": "https://cdn-icons-png.flaticon.com/512/7991/7991921.png",
    "medicine": "https://cdn-icons-png.flaticon.com/512/2965/2965567.png",
    "lab": "https://cdn-icons-png.flaticon.com/512/2966/2966401.png",
    "surgery": "https://cdn-icons-png.flaticon.com/512/2966/2966437.png",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _profileDrawer(),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            color: kTeal,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                _sliverAppBar(),
                SliverToBoxAdapter(
                  child: isLoading ? const DashboardShimmer() : _mainContent(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: CareAIBar(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CareChatScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final collapsed =
              constraints.biggest.height <=
              kToolbarHeight + MediaQuery.of(context).padding.top + 10;
          return DashboardAppBar(
            isCollapsed: collapsed,
            expandedBar: _expandedBar(),
            collapsedBar: _collapsedBar(),
          );
        },
      ),
    );
  }

  Widget _collapsedBar() => Padding(
    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6),
    child: Row(
      children: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _searchBar(isCollapsed: true)),
      ],
    ),
  );
  String selectedLocation = ""; // <-- add this
  Widget _expandedBar() => Padding(
    padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // LOCATION SELECT
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                final location = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocationPickerScreen(),
                  ),
                );

                if (location != null) {
                  setState(() {
                    selectedLocation = location; // <-- FIXED
                  });
                }
              },
              child: Text(
                selectedLocation.isEmpty ? "Select Location" : selectedLocation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                "PLUS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        const Text(
          "Find the care you need.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 14),

        _searchBar(isCollapsed: false),
      ],
    ),
  );

  Widget _searchBar({required bool isCollapsed}) {
    return Container(
      height: isCollapsed ? 38 : 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search, color: kTealDark, size: isCollapsed ? 18 : 22),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              autofocus: false,
              cursorColor: kTealDark,
              style: TextStyle(
                color: Colors.black87,
                fontSize: isCollapsed ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: animatedText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: isCollapsed ? 12 : 14,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget drawerTileProvider(String title, IconData icon, Widget page) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, _) => ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () => nav.navigateTo(context, page),
      ),
    );
  }

  void _handleTrendingTap(String url) {
    if (url == "/all-doctor") {

      print("doctor screen tapped : ");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DoctorFilterScreen()),
      );
    } else if (url == "/all-hospital") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HospitalFilterScreen()),
      );
    } else if (url.startsWith("http")) {
      // FUTURE: External web links
      debugPrint("Open external: $url");
    } else {
      debugPrint("No action defined for: $url");
    }
  }


  // ================= MAIN CONTENT ====================

  Widget _mainContent() {
    final home = Provider.of<HomeController>(context);

    if (home.isLoading || home.homeLayout == null) {
      return const DashboardShimmer();
    }

    final layout = home.homeLayout!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🖼️ SLIDER
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: layout.sliderImg,
                height: 160,
                width: double.infinity,
                fit: BoxFit.fill,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(height: 160, color: Colors.white),
                ),
                errorWidget: (_, __, ___) => Icon(Icons.error),
              ),
            ),

            const SizedBox(height: 25),

            // 🔥 CATEGORIES
            const Text(
              "Browse Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Consumer<HomeHeaderController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.headerList.isEmpty) {
                  return const Text("No categories available");
                }

                return SizedBox(
                  height: 55,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemCount: controller.headerList.length,
                    itemBuilder: (_, i) {
                      final item = controller.headerList[i];

                      return GestureDetector(
                        onTap: () {
                          // 👉 OPEN CHATBOT WITH CATEGORY NAME
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CareChatScreen(selectedTopic: item["text"]),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal.shade600, Colors.tealAccent.shade700],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(color: Colors.teal.shade200, blurRadius: 6),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              item["text"],
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );

              },
            ),

            const SizedBox(height: 25),

            // ⭐ POPULAR SERVICES GRID
            const Text(
              "Popular Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: layout.trendingBanner.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (_, i) {
            final b = layout.trendingBanner[i];

            return GestureDetector(
              onTap: () {
                _handleTrendingTap(b.url);
              },
              child: Container(
                decoration: boxWhite(),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: b.image,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        b.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),


        const SizedBox(height: 30),

            // 🏥 HOSPITAL LIST SECTION
            const Text(
              "Top Hospitals Nearby",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Consumer<HomeController>(
              builder: (_, home, __) {
                if (home.isLoading) {
                  return _hospitalShimmer(); // ⭐ LOADING UI
                }

                if (home.hospitals.isEmpty) {
                  return const Text("No hospitals found ❗");
                }

                return SizedBox(
                  height: 210,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: home.hospitals.length,
                    itemBuilder: (_, i) {
                      final h = home.hospitals[i];

                      final imageUrl = (h.profile != null && h.profile!.isNotEmpty)
                          ? h.profile!
                          : "https://cdn-icons-png.flaticon.com/512/3103/3103472.png";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HospitalDetailScreen(hospitalId: h.id),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 170,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 110,
                                    width: double.infinity,
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(color: Colors.white),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 40),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      h.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),

                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: Colors.teal),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            h.city ?? "Unknown",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),


            const SizedBox(height: 30),

            // 👨‍⚕️ TOP DOCTORS
            const Text(
              "Top Doctors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemCount: home.doctors.length,
                itemBuilder: (_, index) {
                  final d = home.doctors[index];

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctorId: d.id)),
                    ),
                    child: Container(
                      width: 165,
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(
                              d.profile ?? "https://cdn-icons-png.flaticon.com/512/3774/3774299.png",
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(d.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: 3),
                          Text("${d.experience} yrs experience",
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          SizedBox(height: 5),
                          Chip(
                            backgroundColor: Colors.teal,
                            label: Text("Book", style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            const PromoSurgeries(),
            // const SizedBox(height: 25),
            // const BestOffersSection(),
          ],
        ),
      ),
    );
  }







  Widget _hospitalShimmer() {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          width: 170,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: [
                Container(height: 110, width: double.infinity, color: Colors.grey),
                const SizedBox(height: 10),
                Container(height: 15, width: 100, color: Colors.grey),
                const SizedBox(height: 6),
                Container(height: 12, width: 60, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _profileDrawer() {
    final name = userData?["name"] ?? "Guest User";
    final phone = userData?["phone"] ?? "No phone";
    final email=userData?['email'] ?? "Not Available";

    // -------- FIX: Correct profile key -----------
    String img = userData?["profile"] ?? "";

    // -------- FIX: Build Full URL -----------
    if (img.isEmpty) {
      img = "https://cdn-icons-png.flaticon.com/512/1077/1077012.png";
    } else if (!img.startsWith("http")) {
      img = "https://hospitalquee.onrender.com/$img";
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.80,
      child: DashboardDrawer(
        drawerContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ PROFILE HEADER ------------------
            InkWell(
              onTap: () {
                Navigator.pop(context);

                if (userData == null || userData!["userId"] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("User not found! Please login again."),
                    ),
                  );
                  return;
                }

                String userId = userData!["userId"]; // ✔ correct key

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileDetailsScreen(userId: userId),
                  ),
                );
              },

              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kTealLight.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(img),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "+91 $phone",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "$email",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ------------------- MENU ITEMS ----------------------
            DrawerTile(
              title: "Medical Records",
              icon: Icons.folder_special,
              onTap: () => Provider.of<NavigationProvider>(
                context,
                listen: false,
              ).navigateTo(context, MedicalRecords()),
            ),

            DrawerTile(
              title: "Appointments",
              icon: Icons.calendar_month,
              onTap: () => Provider.of<NavigationProvider>(
                context,
                listen: false,
              ).navigateTo(context, AppointmentHistoryScreen()),
            ),

            DrawerTile(
              title: "Lab Tests",
              icon: Icons.bloodtype,
              onTap: () => Provider.of<NavigationProvider>(
                context,
                listen: false,
              ).navigateTo(context, LabtestScreen()),
            ),

            DrawerTile(
              title: "Medicine Orders",
              icon: Icons.medication,
              onTap: () {},
            ),

            DrawerTile(
              title: "Online Consultations",
              icon: Icons.video_call,
              onTap: () {},
            ),

            DrawerTile(title: "Feedback", icon: Icons.feedback, onTap: () {}),

            DrawerTile(title: "Payments", icon: Icons.payment, onTap: () {}),

            const Spacer(),

            // ------------------- LOGOUT BUTTON -------------------
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                await PrefUtils.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/user_login',
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget drawerTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
