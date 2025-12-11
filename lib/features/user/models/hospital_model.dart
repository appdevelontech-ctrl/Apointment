class HospitalModel {
  String id;
  String name;
  String email;
  String phone;
  String? profile;
  String city;
  String state;
  String address;
  String? about;
  String? location;

  HospitalModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profile,
    required this.city,
    required this.state,
    required this.address,
    this.about,
    this.location,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json["_id"],
      name: json["username"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      profile: json["profile"],
      city: json["city"] ?? "",
      state: json["statename"] ?? "",
      address: json["address"] ?? "",
      about: json["about"],
      location: json["location"],
    );
  }
}
