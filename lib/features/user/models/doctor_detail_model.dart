class DoctorDetailsModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String gender;
  final String dob;

  final String profile;
  final String about;
  final int? experience;
  final int? salary;

  final String location;
  final String address;
  final String city;
  final String state;

  final List<String> subDepartments;
  final List<dynamic> educationList;

  final List<dynamic> headId; // Hospitals doctor works in
  final Map<String, dynamic> schedule; // Weekly schedule

  DoctorDetailsModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.dob,
    required this.profile,
    required this.about,
    required this.experience,
    required this.salary,
    required this.address,
    required this.city,
    required this.state,
    required this.location,
    required this.subDepartments,
    required this.educationList,
    required this.headId,
    required this.schedule,
  });

  factory DoctorDetailsModel.fromJson(Map<String, dynamic> json) {
    String finalLocation;

    if (json["location"] == null || json["location"] == "") {
      finalLocation = "${json["address"] ?? ""}, ${json["city"] ?? ""}, ${json["statename"] ?? ""}";
    } else {
      finalLocation = json["location"];
    }

    return DoctorDetailsModel(
      id: json["_id"],
      name: json["username"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      gender: json["gender"] == "1" ? "Male" : "Female",
      dob: json["DOB"]?.toString().substring(0, 10) ?? "",

      profile: json["profile"] == null
          ? "https://cdn-icons-png.flaticon.com/512/1077/1077012.png"
          : "https://hospitalquee.onrender.com/${json["profile"]}",

      about: json["about"] ?? "",
      experience: json["Experience"],
      salary: json["Salary"],

      address: json["address"] ?? "",
      city: json["city"] ?? "",
      state: json["statename"] ?? "",
      location: finalLocation,

      subDepartments: List<String>.from(json["subDepartments"] ?? []),
      educationList: List<dynamic>.from(json["educationList"] ?? []),

      headId: List<dynamic>.from(json["headId"] ?? []),
      schedule: json["schedule"] ?? {},
    );
  }
}
