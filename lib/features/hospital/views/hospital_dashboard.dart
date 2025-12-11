
// features/hospital/views/hospital_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hospital_model.dart';
import '../../../shared/utils/preferences.dart';
import '../../../shared/widgets/glass_container.dart';
import 'my_user_screen.dart';

class HospitalDashboard extends StatelessWidget {
  final Hospital hospital;
  const HospitalDashboard({Key? key, required this.hospital}) : super(key: key);

  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                           GREETING FUNCTION
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 20) return "Good Evening";
    return "Good Night";
  }

  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                           MAIN BUILD
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(context),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00695C),
              Color(0xFF004D40),
              Color(0xFF00251A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, isTablet),

              // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
              // PAGE BODY
              // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? size.width * 0.1 : 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHospitalCard(isTablet),
                      const SizedBox(height: 35),
                      _buildStatsGrid(size, isTablet),
                      const SizedBox(height: 35),
                      _buildSpecialities(isTablet),
                      const SizedBox(height: 30),
                      _buildQuickActions(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                           SLIVER APPBAR
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  SliverAppBar _buildSliverAppBar(BuildContext context, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 180 : 150,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,

      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, "/hospital_profile"),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(hospital.profile),
            ),
          ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.only(left: 20, bottom: 35, right: 20),
          alignment: Alignment.bottomLeft,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xCC004D40),
                Color(0xCC00251A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              /// GREETING TEXT
              Text(
                _getGreeting(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 2),

              /// HOSPITAL NAME
              Text(
                 hospital.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF004D40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Logout?",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: Colors.cyanAccent,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                PrefUtils.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/hospital_login',
                      (route) => false,
                );
              },
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                      HOSPITAL PROFILE CARD
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  Widget _buildHospitalCard(bool isTablet) {
    return GlassContainer(
      borderRadius: 28,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 70 : 50,
            backgroundImage: NetworkImage(hospital.profile),
            backgroundColor: Colors.white24,
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 30 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "${hospital.city}, ${hospital.state}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.cyanAccent, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hospital.address,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.verified,
                        color: Colors.cyanAccent, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "NABH Accredited",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                         STATS GRID (RESPONSIVE)
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  Widget _buildStatsGrid(Size size, bool isTablet) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        SizedBox(
          width: isTablet ? 220 : (size.width / 2) - 30,
          child: _buildStatCard("Total Beds", "104+", Icons.hotel, Colors.cyan),
        ),
        SizedBox(
          width: isTablet ? 220 : (size.width / 2) - 30,
          child: _buildStatCard("Doctors", "290+", Icons.person_outline,
              Colors.indigo),
        ),
        SizedBox(
          width: isTablet ? 220 : (size.width / 2) - 30,
          child:
          _buildStatCard("Staff", "317+", Icons.groups, Colors.orange),
        ),
        SizedBox(
          width: isTablet ? 220 : (size.width / 2) - 30,
          child: _buildStatCard(
              "Specialities", "36+", Icons.local_hospital, Colors.purple),
        ),
      ],
    );
  }

  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                         STAT CARD
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                         SPECIALITIES
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  Widget _buildSpecialities(bool isTablet) {
    return GlassContainer(
      borderRadius: 24,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services,
                  color: Colors.cyanAccent, size: 28),
              const SizedBox(width: 12),
              Text(
                "Our Specialities",
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: hospital.subDepartments.map((dept) {
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  dept,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                         QUICK ACTIONS
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  Widget _buildQuickActions() {
    return Column(
      children: [
        Text(
          "Quick Actions",
          style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        const SizedBox(height: 18),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 30,
          runSpacing: 25,
          children: [
            _actionButton(Icons.people, "Manage Doctors", Colors.teal),
            _actionButton(
                Icons.calendar_today, "Appointments", Colors.indigo),
            _actionButton(Icons.bar_chart, "Analytics", Colors.purple),
            _actionButton(Icons.settings, "Settings", Colors.grey),
          ],
        ),
      ],
    );
  }

  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                           ACTION BUTTON
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  Widget _actionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Icon(icon, size: 34, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  //                           DRAWER
  // :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF004D40),
              Color(0xFF00251A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(hospital.profile),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        hospital.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _drawerItem(
                icon: Icons.person,
                title: "Profile",
                onTap: () =>
                    Navigator.pushNamed(context, "/hospital_profile"),
              ),

              _drawerItem(
                icon: Icons.group,
                title: "My Users",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyUsersScreen(hospitalId: hospital.id), // Ye hospital.id login se aayega
                  ),
                ),
              ),
              _drawerItem(
                icon: Icons.lock,
                title: "Privacy Policy",
                onTap: () =>
                    Navigator.pushNamed(context, "/privacy_policy"),
              ),

              _drawerItem(
                icon: Icons.settings,
                title: "Settings",
                onTap: () =>
                    Navigator.pushNamed(context, "/hospital_settings"),
              ),

              const Spacer(),

              _drawerItem(
                icon: Icons.logout,
                title: "Logout",
                color: Colors.redAccent,
                onTap: () => _confirmLogout(context),

              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
