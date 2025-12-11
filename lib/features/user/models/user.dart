class UserModel {
  final String id;
  final String phone;
  final int type;
  final int empType;
  final int verified;

  final String about;
  final List<dynamic> department;

  final String doc1;
  final String doc2;
  final String doc3;
  final String profile;

  final String pHealthHistory;
  final String cHealthStatus;
  final String company;

  final List<dynamic> nurse;
  final List<dynamic> calls;

  final int wallet;
  final Map<String, dynamic> schedule;
  final Map<String, dynamic> stats;

  UserModel({
    required this.id,
    required this.phone,
    required this.type,
    required this.empType,
    required this.verified,
    required this.about,
    required this.department,
    required this.doc1,
    required this.doc2,
    required this.doc3,
    required this.profile,
    required this.pHealthHistory,
    required this.cHealthStatus,
    required this.company,
    required this.nurse,
    required this.calls,
    required this.wallet,
    required this.schedule,
    required this.stats,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"] ?? "",
      phone: json["phone"] ?? "",
      type: json["type"] ?? 0,
      empType: json["empType"] ?? 0,
      verified: json["verified"] ?? 0,

      about: json["about"] ?? "",
      department: json["department"] ?? [],

      doc1: json["Doc1"] ?? "",
      doc2: json["Doc2"] ?? "",
      doc3: json["Doc3"] ?? "",
      profile: json["profile"] ?? "",

      pHealthHistory: json["pHealthHistory"] ?? "",
      cHealthStatus: json["cHealthStatus"] ?? "",
      company: json["company"] ?? "",

      nurse: json["nurse"] ?? [],
      calls: json["calls"] ?? [],

      wallet: json["wallet"] ?? 0,
      schedule: json["schedule"] ?? {},
      stats: json["stats"] ?? {},
    );
  }
}
