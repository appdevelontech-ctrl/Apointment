class UserModel {
  final String id;
  final String phone;

  final int type;
  final int empType;
  final int verified;

  final String about;
  final String company;
  final String profile;

  final List<dynamic> department;
  final List<dynamic> nurse;
  final List<dynamic> calls;

  final String doc1;
  final String doc2;
  final String doc3;

  final String pHealthHistory;
  final String cHealthStatus;

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
    required this.company,
    required this.profile,
    required this.department,
    required this.nurse,
    required this.calls,
    required this.doc1,
    required this.doc2,
    required this.doc3,
    required this.pHealthHistory,
    required this.cHealthStatus,
    required this.wallet,
    required this.schedule,
    required this.stats,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",

      type: json["type"] ?? 0,
      empType: json["empType"] ?? 0,
      verified: json["verified"] ?? 0,

      about: json["about"] ?? "",
      company: json["company"] ?? "",
      profile: json["profile"] ?? "",

      department: json["department"] ?? [],
      nurse: json["nurse"] ?? [],
      calls: json["calls"] ?? [],

      doc1: json["Doc1"] ?? "",
      doc2: json["Doc2"] ?? "",
      doc3: json["Doc3"] ?? "",

      pHealthHistory: json["pHealthHistory"] ?? "",
      cHealthStatus: json["cHealthStatus"] ?? "",

      wallet: json["wallet"] ?? 0,
      schedule: json["schedule"] ?? {},
      stats: json["stats"] ?? {},
    );
  }
}
