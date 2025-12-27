import 'dart:ffi';
 import 'package:appointment_app/features/user/views/profilescreeen.dart';
import 'package:appointment_app/features/user/views/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/utils/preferences.dart';
import '../controllers/home_controller.dart';
import '../controllers/home_header_controller.dart';
import '../providers/navigation_provider.dart';
import '../services/user_api_service.dart';
import '../widgets/dashboard_widgets.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_smooth.dart';
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

class _DashboardScreenState extends State<UserDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _typewriterController;
  late AnimationController _fadeController;
  String fullText = "Search for medicines, doctors...";
  String animatedText = "";
  int textIndex = 0;
  Map<String, dynamic>? userData;
  String selectedLocation = "";
  bool _hasLoggedDoctorImages = false; // Flag to prevent spam logging

  @override
  void initState() {
    super.initState();
    _typewriterController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeController>(context, listen: false).loadHomeData();
      Provider.of<HomeHeaderController>(context, listen: false).loadHeaders();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refreshUserFromApi();   // 🔥 IMPORTANT
      await _loadUser();            // drawer refresh
    });
    _startTypewriter();
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final data = await PrefUtils.getUserData();
    if (!mounted) return;

    setState(() {
      userData = data;
    });
  }

  Future<void> refreshUserFromApi() async {
    final userId = await PrefUtils.getUserId();
    if (userId == null) return;

    final apiProfile = await UserApiService.getCurrentUser(userId);

    await PrefUtils.saveUserData({
      "userId": apiProfile["_id"],
      "name": apiProfile["username"],
      "phone": apiProfile["phone"],
      "email": apiProfile["email"],
      "profile": apiProfile["profile"],
      "city": apiProfile["city"],
      "statename": apiProfile["statename"],
      "pincode": apiProfile["pincode"],
      "about": apiProfile["about"],
    });
  }



  void _startTypewriter() {
    _typewriterController.repeat(period: const Duration(seconds: 4));
    _typewriterController.addListener(() {
      final progress = _typewriterController.value;
      final charIndex = (progress * fullText.length).floor();
      if (mounted) {
        setState(() {
          animatedText = fullText.substring(0, charIndex.clamp(0, fullText.length));
        });
      }
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      Provider.of<HomeController>(context, listen: false).loadHomeData(),
      Provider.of<HomeHeaderController>(context, listen: false).loadHeaders(),
    ]);
  }

  void _handleTrendingTap(String url) {
    if (url == "/all-doctor") {
      SmoothNavigator.push(
        context,
        const DoctorFilterScreen(),
      );

    } else if (url == "/all-hospital") {
      SmoothNavigator.push(
        context,
        const HospitalFilterScreen(),
      );

    } else if (url.startsWith("http")) {
      debugPrint("Open external: $url");
      // TODO: Use url_launcher to open link
    } else {
      debugPrint("No action defined for: $url");
    }
  }
  IconData getServiceIcon(String title) {
    switch (title.toLowerCase()) {
      case 'doctor':
      case 'doctors':
        return Icons.medical_services;

      case 'hospital':
      case 'hospitals':
        return Icons.local_hospital;

      case 'lab test':
      case 'lab tests':
        return Icons.science;

      case 'medicine':
      case 'medicines':
        return Icons.medication;

      case 'appointment':
        return Icons.calendar_month;

      case 'online consultation':
        return Icons.video_call;

      default:
        return Icons.health_and_safety;
    }
  }



  // Optimized image loader with RepaintBoundary and lighter placeholder
  Widget _buildCachedImage({
    required String? imageUrl,
    required Widget fallbackWidget,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    int? memCacheHeight,
    bool useShimmer = true, // Option for shimmer vs spinner
  }) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return fallbackWidget;
    }
    // Conditional debug logging for doctors - only once per session
    if (width == 80 && height == 80 && !_hasLoggedDoctorImages) {
      debugPrint("Doctor image URL (first load): $imageUrl");
      _hasLoggedDoctorImages = true;
    }
    return RepaintBoundary(
      child: CachedNetworkImage(
        imageUrl: imageUrl.trim(),
        height: height,
        width: width,
        fit: fit,
        memCacheHeight: memCacheHeight ?? 150, // Even smaller cache for perf
        placeholder: (context, url) => useShimmer
            ? Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(width ?? 0),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
        )
            : Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: kTeal),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint("Image load error: $error for URL: $url");
          return fallbackWidget;
        },
        fadeInDuration: const Duration(milliseconds: 150), // Faster fade
        fadeOutDuration: const Duration(milliseconds: 50),
      ),
    );
  }
  Widget _buildHospitalAsset(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAF9), // 🔥 soft medical bg
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/hospital_1217730.png',
          height: height * 0.6, // 🔥 responsive icon size
          width: height * 0.6,
          fit: BoxFit.contain, // ✅ IMPORTANT
          errorBuilder: (_, __, ___) {
            return const Icon(
              Icons.local_hospital,
              size: 40,
              color: kTeal,
            );
          },
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Builder(
        builder: (context) {
          _loadUser(); // 🔥 ALWAYS REFRESH WHEN DRAWER OPENS
          return _profileDrawer();
        },
      ),

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
                SliverToBoxAdapter(child: _mainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final collapsed = constraints.biggest.height <=
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
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.menu, color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _searchBar(isCollapsed: true)),
      ],
    ),
  );

  Widget _expandedBar() => Padding(
    padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Profile Avatar
            Builder(
              builder: (context) => InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.menu, color: Colors.white, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Location Selector
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  final location = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
                  );
                  if (location != null && mounted) {
                    setState(() => selectedLocation = location);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selectedLocation.isEmpty ? "Select Location" : selectedLocation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Profile button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: IconButton(
                onPressed: () {
                  if (userData == null || userData!["userId"] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not found, please login again")),
                    );
                    return;
                  }

                  SmoothNavigator.push(
                    context,
                      ProfileViewScreen()
                  );
                },

                icon: const Icon(Icons.person_outline, color: Colors.white),
              ),

            ),
          ],
        ),
        const SizedBox(height: 20),
        _searchBar(isCollapsed: false),
      ],
    ),
  );

  Widget _searchBar({required bool isCollapsed}) {
    return DashboardSearchBar(
      isCollapsed: isCollapsed,
      hint: animatedText,
      onTap: () {
        SmoothNavigator.push(
          context,
          const GlobalSearchScreen(),
        );

      },
    );
  }

  String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String getPopularServiceIconAsset(String title) {
    final key = normalize(title);

    const map = {
      'instant video consultation': 'assets/icons/telemedicine_9970212.png',
      'find doctors near you': 'assets/icons/doctor_872098.png',
      'lab tests': 'assets/icons/chemistry_5398776.png',
      'surgeries': 'assets/icons/analysis_18494392.png',
      'find hospital near you': 'assets/icons/hospital_1217730.png',
    };

    return map[key] ?? 'assets/icons/doctor_872098.png';
  }

  Widget popularServiceItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              getPopularServiceIconAsset(title),
              height: 64, // 🔥 BIGGER ICON
              width: 64,
              fit: BoxFit.contain,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double getHospitalRating(dynamic rating) {
    if (rating == null) return 4.5; // fallback
    if (rating is num) return rating.toDouble();
    return 4.5;
  }



  Widget _mainContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child:
      Consumer<HomeController>(
        builder: (context, home, _) {
          if (home.isLoading || home.homeLayout == null) {
            return const Column(
              children: [
                const SliderShimmer(),
                const SizedBox(height: 8),
                const ServiceGridShimmer(),
                const SizedBox(height: 8),
                const DoctorShimmer(),

                SizedBox(height: 8),
                const HospitalShimmer(),
              ],
            );
          }
          final layout = home.homeLayout!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SLIDER
              RepaintBoundary(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:
                  _buildCachedImage(
                    imageUrl: layout.sliderImg,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheHeight: 280,
                    fallbackWidget: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.image, size: 50, color: Colors.white70),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // POPULAR SERVICES - Simplified animation (only on first build)
              const Text(
                "Popular Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  int crossAxisCount = 2;
                  if (width >= 900) {
                    crossAxisCount = 4;
                  } else if (width >= 600) {
                    crossAxisCount = 3;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: layout.trendingBanner.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3, // 🔥 balanced height
                    ),
                    itemBuilder: (_, i) {
                      final b = layout.trendingBanner[i];
                      return popularServiceItem(
                        title: b.title,
                        onTap: () => _handleTrendingTap(b.url),
                      );
                    },
                  );
                },
              ),




              const SizedBox(height: 12),
              // HOSPITALS - Simplified animation
              const Text(
                "Top Hospitals Nearby",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (home.hospitals.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No hospitals found ❗",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth < 360 ? 145.0 : 160.0;
                    final cardHeight = constraints.maxWidth < 360 ? 205.0 : 220.0;

                    return SizedBox(
                      height: cardHeight,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: home.hospitals.length.clamp(0, 6),
                        itemBuilder: (_, i) {
                          final h = home.hospitals[i];

                          return GestureDetector(
                            onTap: () {
                              SmoothNavigator.push(
                                context,
                                HospitalDetailScreen(hospitalId: h.id),
                              );
                            },
                            child: Container(
                              width: cardWidth,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ---------- IMAGE ----------
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child: Stack(
                                      children: [
                                        _buildHospitalAsset(90),
                                        Container(
                                          height: 95,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.25),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ---------- CONTENT ----------
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Name
                                        Text(
                                          h.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        // Location
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 13, color: kTeal),
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
                                        ),

                                        const SizedBox(height: 8),





                                        // CTA
                                        Container(
                                          width: double.infinity,
                                          padding:
                                          const EdgeInsets.symmetric(vertical: 6),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: kTeal.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Text(
                                            "View Details",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: kTeal,
                                            ),
                                          ),
                                        ),
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


              const SizedBox(height: 12),

              // DOCTORS - Optimized with shimmer and lighter perf
              const Text(
                "Top Doctors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (home.doctors.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(color: kTeal)),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: home.doctors.length.clamp(0, 5),
                    itemBuilder: (_, index) {
                      final d = home.doctors[index];

                      return GestureDetector(
                        onTap: () {
                          SmoothNavigator.push(
                            context,
                            DoctorDetailsScreen(doctorId: d.id),
                          );
                        },
                        child: Container(
                          width: 155,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // ---------- PROFILE IMAGE ----------
                              ClipOval(
                                child: RepaintBoundary(
                                  child: _buildCachedImage(
                                    imageUrl: d.profile,
                                    height: 84,
                                    width: 84,
                                    fit: BoxFit.cover,
                                    memCacheHeight: 160,
                                    fallbackWidget: Container(
                                      height: 84,
                                      width: 84,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEFF6F5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: kTeal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ---------- NAME ----------
                              Text(
                                d.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // ---------- EXPERIENCE ----------
                              Text(
                                "${d.experience} yrs experience",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const Spacer(),

                              // ---------- CTA ----------
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: kTeal.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  "Book Appointment",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: kTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),
              const PromoSurgeries(),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }



  Widget _profileDrawer() {
    final name = userData?["name"] ?? "Guest User";
    final phone = userData?["phone"] ?? "No phone";
    final email = userData?['email'] ?? "Not Available";
    String img = userData?["profile"] ?? "";
    if (img.isEmpty) {
      img = "https://cdn-icons-png.flaticon.com/512/1077/1077012.png";
    } else if (!img.startsWith("http")) {
      img = "https://hospitalquee.onrender.com/$img";
    }
    return DashboardDrawer(
      drawerContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              if (userData == null || userData!["userId"] == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not found! Please login again.")),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>ProfileViewScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kTealLight.withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "+91 $phone",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          DrawerTile(
            title: "Appointments",
            icon: Icons.calendar_month,
            onTap: () => Provider.of<NavigationProvider>(context, listen: false)
                .navigateTo(context,   AppointmentHistoryScreen()),
          ),
          DrawerTile(
            title: "Delete Account",
            icon: Icons.delete_forever,
            onTap: () => _showDeleteAccountDialog(),
          ),


          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () => _showLogoutDialog(),
          ),


          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Delete Account"),
        content: const Text(
          "This action is permanent and cannot be undone.\n\nDo you want to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);

              // 🔥 TEMP BEHAVIOUR
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Delete account feature will be available soon",
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text("Delete",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }


  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await PrefUtils.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/user_login',
                      (route) => false,
                );
              }
            },
            child: const Text("Logout",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

}

class SliderShimmer extends StatelessWidget {
  const SliderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: shimmerWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}


// Optimized Shimmer
class DashboardShimmerOptimized extends StatelessWidget {
  final bool grid;
  final bool list;
  const DashboardShimmerOptimized({
    super.key,
    this.grid = false,
    this.list = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: grid
          ? GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      )
          : list
          ? SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemExtent: 150,
          itemCount: 3,
          itemBuilder: (_, __) => Container(
            width: 150,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      )
          : Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
Widget shimmerWrapper({required Widget child}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    period: const Duration(milliseconds: 1400), // 🔥 smooth shimmer
    child: child,
  );
}


class ServiceGridShimmer extends StatelessWidget {
  const ServiceGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return shimmerWrapper(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (_, __) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon placeholder
                Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),

                // Title line
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class DoctorShimmer extends StatelessWidget {
  const DoctorShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: shimmerWrapper(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (_, __) {
            return Container(
              width: 155,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  // Profile circle
                  Container(
                    height: 84,
                    width: 84,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Name
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Experience
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  const Spacer(),

                  // CTA
                  Container(
                    height: 28,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


class HospitalShimmer extends StatelessWidget {
  const HospitalShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: shimmerWrapper(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (_, __) {
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- IMAGE PLACEHOLDER ----------
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hospital Name
                        Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Location row
                        Row(
                          children: [
                            Container(
                              height: 12,
                              width: 12,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // CTA Placeholder
                        Container(
                          height: 28,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


