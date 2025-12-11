class DoctorListModel {
  final String id;
  final String name;
  final String? profile;
  final int? experience;

  DoctorListModel({
    required this.id,
    required this.name,
    this.profile,
    this.experience,
  });

  factory DoctorListModel.fromJson(Map<String, dynamic> json) {
    return DoctorListModel(
      id: json["_id"] ?? "",
      name: json["username"] ?? "Unknown Doctor",
      profile: json["profile"] == null || json["profile"] == ""
          ? null
          : "https://hospitalquee.onrender.com/${json['profile']}",
      experience: json["Experience"] ?? 0,
    );
  }
}
