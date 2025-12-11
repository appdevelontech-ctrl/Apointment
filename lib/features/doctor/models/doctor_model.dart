// features/doctor/models/doctor_model.dart

import 'package:html/parser.dart'; // 👈 for removing HTML from 'about'

class Doctor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profile;
  final String about;              // Plain text (no HTML)
  final String city;
  final String state;
  final String address;
  final int experience;
  final double salary;
  final List<String> subDepartments;
  final Map<String, dynamic> schedule;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profile,
    required this.about,
    required this.city,
    required this.state,
    required this.address,
    required this.experience,
    required this.salary,
    required this.subDepartments,
    required this.schedule,
  });

  // Clean HTML from 'about'
  static String _stripHtml(String htmlText) {
    var doc = parse(htmlText);
    return doc.body?.text.trim() ?? '';
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',

      // clean "Dr." prefix automatically
      name: json['username']?.toString().replaceAll("Dr.", "").trim() ?? '',

      email: json['email'] ?? '',
      phone: json['phone'] ?? '',

      profile: json['profile'] != null
          ? "https://hospitalquee.onrender.com/${json['profile']}"
          : "https://via.placeholder.com/150",

      about: json['about'] != null ? _stripHtml(json['about']) : "No bio available",

      city: json['city'] ?? '',
      state: json['statename'] ?? '',
      address: json['address'] ?? '',

      experience: json['Experience'] ?? 0,
      salary: (json['Salary'] ?? 0).toDouble(),

      subDepartments: List<String>.from(json['department'] ?? []),

      schedule: json['schedule'] ?? {},
    );
  }
}
