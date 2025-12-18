import 'dart:ffi';
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
    _loadUser();
    _startTypewriter();
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadUser() async {
    userData = await PrefUtils.getUserData();
    if (mounted) setState(() {});
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

  // New method for hospital image - uses asset if no profile
  Widget _buildHospitalImage(String? profileUrl, double height, double width) {
    if (profileUrl?.isNotEmpty != true) {
      // Use asset image for fast loading
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Container(
          height: height,
          width: width,
          child: Image.asset(
            'assets/images/hospital-building.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if asset fails
              return Container(
                height: height,
                color: Colors.grey.shade200,
                child: const Icon(Icons.local_hospital, size: 35),
              );
            },
          ),
        ),
      );
    }
    // Use network if profile exists
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: _buildCachedImage(
        imageUrl: profileUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        useShimmer: true,
        fallbackWidget: Container(
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.local_hospital, size: 35),
        ),
      ),
    );
  }

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
                onPressed: () {}, // TODO: Navigate to profile
                icon: const Icon(Icons.person_outline, color: Colors.white, size: 22),
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

  Widget _mainContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Consumer<HomeController>(
        builder: (context, home, _) {
          if (home.isLoading || home.homeLayout == null) {
            return const Column(
              children: [
                SizedBox(height: 140, child: DashboardShimmerOptimized()),
                SizedBox(height: 8),
                SizedBox(height: 160, child: DashboardShimmerOptimized(grid: true)),
                SizedBox(height: 8),
                SizedBox(height: 180, child: HospitalShimmer()), // Custom shimmer for hospitals
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
                  child: _buildCachedImage(
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
              SizedBox(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: layout.trendingBanner.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (_, i) {
                    final b = layout.trendingBanner[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _handleTrendingTap(b.url),
                      child: Container( // Simplified to Container for perf (no AnimatedContainer)
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFF8F9FA)], // Lighter grey
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kTeal.withOpacity(0.08), // Lighter shadow
                              blurRadius: 6, // Reduced blur
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildCachedImage(
                                imageUrl: b.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                memCacheHeight: 200, // Smaller
                                fallbackWidget: Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.category, size: 35, color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                              child: Text(
                                b.title,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
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
                  child: Text("No hospitals found ❗", style: TextStyle(color: Colors.grey)),
                )
              else
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemExtent: 150,
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

                        child: Container( // No AnimatedContainer
                          width: 150,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.white, Color(0xFFF8F9FA)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04), // Much lighter
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Use new method for fast asset fallback
                              _buildHospitalImage(h.profile, 90, double.infinity),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 12, color: kTeal),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              h.city ?? "Unknown",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemExtent: 140,
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
                        child: Container( // Simplified
                          width: 140,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.blue.shade50], // Lighter blue
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: kTeal.withOpacity(0.1), // Lighter
                                blurRadius: 6, // Reduced
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ClipOval(
                                child: _buildCachedImage(
                                  imageUrl: d.profile,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  useShimmer: true, // Enable shimmer for doctors to show loading
                                  fallbackWidget: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                d.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${d.experience} yrs exp",
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kTeal,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  "Book",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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
                MaterialPageRoute(builder: (_) => ProfileDetailsScreen(userId: userData!["userId"])),
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
            title: "Medical Records",
            icon: Icons.folder_special,
            onTap: () => Provider.of<NavigationProvider>(context, listen: false)
                .navigateTo(context, const MedicalRecords()),
          ),
          DrawerTile(
            title: "Appointments",
            icon: Icons.calendar_month,
            onTap: () => Provider.of<NavigationProvider>(context, listen: false)
                .navigateTo(context,   AppointmentHistoryScreen()),
          ),
          DrawerTile(
            title: "Lab Tests",
            icon: Icons.bloodtype,
            onTap: () => Provider.of<NavigationProvider>(context, listen: false)
                .navigateTo(context, const LabtestScreen()),
          ),
          DrawerTile(title: "Medicine Orders", icon: Icons.medication, onTap: () {}),
          DrawerTile(title: "Online Consultations", icon: Icons.video_call, onTap: () {}),
          DrawerTile(title: "Feedback", icon: Icons.feedback, onTap: () {}),
          DrawerTile(title: "Payments", icon: Icons.payment, onTap: () {}),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await PrefUtils.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/user_login', (route) => false);
              }
            },
          ),
          const SizedBox(height: 10),
        ],
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

// Custom Shimmer for Hospitals using asset image
class HospitalShimmer extends StatelessWidget {
  const HospitalShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
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
            child: Column(
              children: [
                // Shimmer with asset image overlay
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Asset image as base
                      Image.asset(
                        'assets/images/hospital-building.png',
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Shimmer overlay for loading effect
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 13,
                          width: 120,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}