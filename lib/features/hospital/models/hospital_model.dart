// features/hospital/models/hospital_model.dart

class Hospital {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profile;
  final String about;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final List<String> subDepartments;
  final List<Certification>? certifications;
  final List<Stat>? stats;

  Hospital({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profile,
    required this.about,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.subDepartments,
    this.certifications,
    this.stats,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['_id'] ?? '',
      name: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profile: json['profile'] != null
          ? 'https://hospitalquee.onrender.com/' + json['profile']
          : 'https://via.placeholder.com/150',
      about: json['about'] ?? 'Premier Healthcare Provider',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['statename'] ?? '',
      pincode: json['pincode'] ?? '',
      subDepartments: List<String>.from(json['subDepartments'] ?? []),
      certifications: json['certifications'] != null
          ? (json['certifications'] as List).map((e) => Certification.fromJson(e)).toList()
          : null,
      stats: json['stats'] != null
          ? (json['stats'] as List).map((e) => Stat.fromJson(e)).toList()
          : null,
    );
  }
}

class Certification {
  final String image;
  final String text;
  Certification({required this.image, required this.text});
  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
    image: json['image'] ?? '',
    text: json['text'] ?? '',
  );
}

class Stat {
  final String value;
  final String label;
  Stat({required this.value, required this.label});
  factory Stat.fromJson(Map<String, dynamic> json) => Stat(
    value: json['value'] ?? '',
    label: json['label'] ?? '',
  );
}