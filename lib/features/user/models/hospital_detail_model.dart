
class HospitalDetailModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String about;
  final String profile;
  final String? location;
  final List<String> subDepartments;
  final List<Map<String, String>> certifications;
  final List<Map<String, String>> stats;
  final List<Map<String, dynamic>> stories;
  final List<String> educationList;

  HospitalDetailModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.about,
    required this.profile,
    required this.location,
    required this.subDepartments,
    required this.certifications,
    required this.stats,
    required this.stories,
    required this.educationList,
  });

  factory HospitalDetailModel.fromJson(Map<String, dynamic> json) {
    return HospitalDetailModel(
      id: json["_id"],
      name: json["username"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      address: json["address"] ?? "",
      about: json["about"]?.replaceAll(RegExp(r'<[^>]*>'), "") ?? "",
      profile: json["profile"] ?? "",
      location: json["location"],
      subDepartments: List<String>.from(json["subDepartments"] ?? []),
      certifications: List<Map<String, String>>.from(
        (json["certifications"] ?? []).map((e) => {
          "image": e["image"],
          "text": e["text"]
        }),
      ),
      stats: List<Map<String, String>>.from(
        (json["stats"] ?? []).map((e) => {
          "value": e["value"],
          "label": e["label"]
        }),
      ),
      stories: List<Map<String, dynamic>>.from(json["stories"] ?? []),
      educationList: List<String>.from(json["educationList"] ?? []),
    );
  }
}
