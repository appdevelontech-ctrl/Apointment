import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/services/api_service.dart';

class HospitalDetailScreen extends StatefulWidget {
  final String hospitalId;
  const HospitalDetailScreen({super.key, required this.hospitalId});

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      final res = await http.get(
        Uri.parse("${ApiService.baseUrl}/get-vendor/${widget.hospitalId}"),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        setState(() {
          data = json["Mpage"];
          loading = false;
          hasError = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        loading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Hospital Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: loading
          ? const _FullScreenLoader()
          : hasError
          ? _errorWidget()
          : RefreshIndicator(
        onRefresh: fetchDetails,
        child: _content(),
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text("Failed to load details", style: TextStyle(fontSize: 18, color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: fetchDetails,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _banner(),
          const SizedBox(height: 20),
          _nameSection(),
          const SizedBox(height: 24),
          if (data?["about"] != null && data!["about"].toString().trim().isNotEmpty) _about(),
          if (data?["stats"] != null && (data!["stats"] as List).isNotEmpty) ...[
            const SizedBox(height: 24),
            _statsSection(),
          ],
          if (data?["certifications"] != null && (data!["certifications"] as List).isNotEmpty) ...[
            const SizedBox(height: 24),
            _certifications(),
          ],
          if (data?["stories"] != null && (data!["stories"] as List).isNotEmpty) ...[
            const SizedBox(height: 24),
            _storiesSection(),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _banner() {
    final profileUrl = data?["profile"] ?? "";
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CachedNetworkImage(
        imageUrl: "https://hospitalquee.onrender.com/$profileUrl",
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey.shade200),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.local_hospital, size: 60, color: Colors.teal),
        ),
      ),
    );
  }

  Widget _nameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data?["username"] ?? "Unknown Hospital",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.teal.shade600, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                data?["location"] ?? "Location not available",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _about() {
    final aboutText = (data?["about"] ?? "").toString().replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return _sectionCard(
      title: "About Hospital",
      child: Text(
        aboutText,
        style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
      ),
    );
  }

  Widget _statsSection() {
    final List stats = data?["stats"] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Key Statistics", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : (constraints.maxWidth > 400 ? 2 : 1);
            return GridView.builder(
              itemCount: stats.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: crossAxisCount == 1 ? 4 : 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (_, i) {
                final item = stats[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.shade100),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            item["value"]?.toString() ?? "-",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item["label"] ?? "Unknown",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _certifications() {
    final certifications = data?["certifications"] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Certifications & Accreditations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: certifications.length,
            itemBuilder: (_, i) {
              final c = certifications[i];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: CachedNetworkImage(
                        imageUrl: c["image"] ?? "",
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        c["text"] ?? "",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _storiesSection() {
    final stories = data?["stories"] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Patient Stories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            itemBuilder: (_, i) {
              final st = stories[i];
              return GestureDetector(
                onTap: () async {
                  final url = Uri.parse(st["link"] ?? "");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: CachedNetworkImage(
                          imageUrl: st["image"] ?? "",
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.play_circle_outline, size: 40),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          st["title"] ?? "Patient Story",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 220, width: double.infinity, color: Colors.white),
            const SizedBox(height: 20),
            Container(height: 32, width: 300, color: Colors.white),
            const SizedBox(height: 12),
            Container(height: 20, width: double.infinity, color: Colors.white),
            const SizedBox(height: 30),
            Container(height: 100, width: double.infinity, color: Colors.white),
          ],
        ),
      ),
    );
  }
}