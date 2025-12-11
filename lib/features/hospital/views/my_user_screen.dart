// features/hospital/views/my_users_screen.dart

import 'package:appointment_app/features/hospital/services/hospital_api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/glass_container.dart';

class MyUsersScreen extends StatefulWidget {
  final String hospitalId;
  const MyUsersScreen({Key? key, required this.hospitalId}) : super(key: key);

  @override
  State<MyUsersScreen> createState() => _MyUsersScreenState();
}

class _MyUsersScreenState extends State<MyUsersScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final List<dynamic> fetchedUsers = await ApiService.getHospitalUsers(widget.hospitalId);
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _cleanName(String name) => name.trim().replaceAll("Dr.", "").trim();

  String _getRole(int empType) {
    switch (empType) {
      case 3: return "Doctor";
      case 4: return "Radiologist / Lab";
      case 5: return "Nurse";
      default: return "Staff";
    }
  }

  Color _getRoleColor(int empType) {
    switch (empType) {
      case 3: return Colors.cyan;
      case 4: return Colors.purple;
      case 5: return Colors.green;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;
    final double horizontalPadding = isTablet ? size.width * 0.1 : 16;
    final double cardRadius = isTablet ? 28 : 20;

    return Scaffold(
      backgroundColor: const Color(0xFF00251A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Users (${users.length})",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isTablet ? 26 : 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : error.isNotEmpty
          ? _buildErrorState(isTablet)
          : users.isEmpty
          ? _buildEmptyState(isTablet)
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
        child: isTablet
            ? _buildGridView(cardRadius)   // Tablet pe Grid
            : _buildListView(cardRadius),  // Mobile pe List
      ),
    );
  }

  // Tablet ke liye Grid View
  Widget _buildGridView(double radius) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) => _buildUserCard(users[index], radius, true),
    );
  }

  // Mobile ke liye List View
  Widget _buildListView(double radius) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildUserCard(users[index], radius, false),
      ),
    );
  }

  Widget _buildUserCard(dynamic user, double radius, bool isGrid) {
    final profileUrl = user['profile'] != null
        ? "${ApiService.baseUrl}/${user['profile']}"
        : "https://via.placeholder.com/150";

    final String cleanName = _cleanName(user['username'] ?? "Unknown User");
    final String role = _getRole(user['empType'] ?? 0);
    final Color roleColor = _getRoleColor(user['empType'] ?? 0);
    final int? experience = user['Experience'];

    return GlassContainer(
      borderRadius: radius,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Opening: $cleanName")),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isGrid ? 12 : 16),
          child: Row(
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: isGrid ? 28 : 34,
                backgroundImage: NetworkImage(profileUrl),
                onBackgroundImageError: (_, __) {},
                child: user['profile'] == null
                    ? Text(
                  cleanName.isNotEmpty ? cleanName[0].toUpperCase() : "?",
                  style: GoogleFonts.poppins(
                    fontSize: isGrid ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 14),

              // Middle Content (Name, Email, Phone)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name - Auto shrink if too long
                    Text(
                      cleanName,
                      style: GoogleFonts.poppins(
                        fontSize: isGrid ? 15 : 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Email
                    Text(
                      user['email'] ?? "No email",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isGrid ? 12 : 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Phone
                    Row(
                      children: [
                        Icon(Icons.phone, size: isGrid ? 13 : 15, color: Colors.white60),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            user['phone'] ?? "N/A",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: isGrid ? 12 : 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right Side: Role Badge + Experience
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Role Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isGrid ? 8 : 10,
                        vertical: isGrid ? 5 : 7,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: roleColor, width: 1.2),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isGrid ? 10 : 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Experience (only if exists)
                    if (experience != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "$experience yrs",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: isGrid ? 10 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildErrorState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.redAccent, size: isTablet ? 80 : 60),
          const SizedBox(height: 20),
          Text(
            "Connection Failed",
            style: GoogleFonts.poppins(fontSize: isTablet ? 24 : 20, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            error.split("Exception: ").last,
            style: TextStyle(color: Colors.white60, fontSize: isTablet ? 16 : 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: fetchUsers,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: isTablet ? 100 : 80, color: Colors.white38),
          const SizedBox(height: 20),
          Text(
            "No Users Found",
            style: GoogleFonts.poppins(fontSize: isTablet ? 26 : 22, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            "Add doctors & staff to see them here",
            style: TextStyle(color: Colors.white60, fontSize: isTablet ? 16 : 14),
          ),
        ],
      ),
    );
  }
}