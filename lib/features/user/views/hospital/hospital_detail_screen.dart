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

  @override
  void initState() {
    fetchDetails();
    super.initState();
  }

  Future<void> fetchDetails() async {
    final res = await http.get(
      Uri.parse("${ApiService.baseUrl}/get-vendor/${widget.hospitalId}"),
    );

    if (res.statusCode == 200) {
      setState(() {
        data = jsonDecode(res.body)["Mpage"];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Hospital Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),

      body: loading ? _loader() : _content(),
    );
  }

  Widget _loader() => Center(
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(width: 200, height: 20, color: Colors.white),
    ),
  );
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
          const SizedBox(height: 20),

          if (data!["about"] != null)
            _about(),

          const SizedBox(height: 20),

          if (data!["stats"] != null && data!["stats"].isNotEmpty)
            _statsSection(),

          const SizedBox(height: 20),

          if (data!["certifications"] != null && data!["certifications"].isNotEmpty)
            _certifications(),

          const SizedBox(height: 20),

          if (data!["stories"] != null && data!["stories"].isNotEmpty)
            _storiesSection(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }


  // 🏥 Banner
  Widget _banner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: "https://hospitalquee.onrender.com/${data!["profile"]}",
        height: 190,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const Icon(Icons.error, size: 40),
      ),
    );
  }

  // 🏥 Name + Location
  Widget _nameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data!["username"],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.teal, size: 18),
            Expanded(
              child: Text(
                data!["location"],
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 📄 About Section
  Widget _about() {
    return _card(
      "About",
      data!["about"].replaceAll(RegExp(r'<[^>]*>'), ""),
    );
  }
  Widget _statsSection() {
    final List stats = data!["stats"] ?? [];

    if (stats.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hospital Stats",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 350 ? 2 : 1;

            return GridView.builder(
              itemCount: stats.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.8,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (_, i) {
                final item = stats[i];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.teal.shade100),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            item["value"] ?? "-",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Label Text
                      Expanded(
                        child: Text(
                          item["label"] ?? "-",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
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


  // 🏅 Certifications
  Widget _certifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Certifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),

        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data!["certifications"].length,
            itemBuilder: (_, i) {
              final c = data!["certifications"][i];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(c["image"], height: 70, width: 180, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        c["text"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // 🎥 Stories (YouTube Links)
  Widget _storiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Patient Stories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),

        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data!["stories"].length,
            itemBuilder: (_, i) {
              final st = data!["stories"][i];

              return GestureDetector(
                onTap: () async => await launchUrl(Uri.parse(st["link"])),
                child: Container(
                  width: 190,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(st["image"], height: 100, width: 200, fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(st["title"],
                            maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
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

  // 🔹 Reusable Card
  Widget _card(String title, String content) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(content),
          ],
        ),
      ),
    );
  }
}
