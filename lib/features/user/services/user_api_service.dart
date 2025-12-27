import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/doctor_model.dart';
import '../models/home_layout_model.dart';
import '../models/hospital_model.dart';

class UserApiService {
  static const baseUrl = "https://hospitalquee.onrender.com";
  static const String googlePlacesKey = 'AIzaSyCcppZWLo75ylSQvsR-bTPZLEFEEec5nrY';

  // =========================================================
  // SEND OTP
  // =========================================================
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    print("📩 [SEND OTP] Phone → $phone");

    final response = await http.post(
      Uri.parse("$baseUrl/login-with-otp/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone, "password": ""}),
    );

    print("📥 Response (${response.statusCode}): ${response.body}");

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      print("✅ SEND OTP SUCCESS");
      print("🆕 newUser: ${data['newUser']}");
      print("👤 existingUser: ${data['existingUser']}");
      print("🔐 hashOtp (bcrypt): ${data['otp']}");
      print("🔢 newOtp (test): ${data['newOtp']}");

      return {
        "success": true,
        "newUser": data["newUser"] ?? false,
        "existingUser": data["existingUser"],
        "hashOtp": data["otp"],
        "otp": data["newOtp"],
        "token": data["token"],
        "userId": data["existingUser"]?["_id"],
      };
    }

    print("❌ SEND OTP FAILED: ${data["message"]}");
    throw Exception(data["message"] ?? "Failed to send OTP");
  }

  // =========================================================
  // VERIFY OTP
  // =========================================================
  static Future<bool> verifyOtp(String hash, String otp) async {
    print("🔐 [VERIFY OTP] OTP → $otp");
    print("🔑 HASH → $hash");

    final response = await http.post(
      Uri.parse("$baseUrl/login-verify-otp/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"HASHOTP": hash, "OTP": otp}),
    );

    print("📥 VERIFY OTP RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    print("🔎 VERIFY SUCCESS? → ${data["success"]}");
    return data["success"] == true;
  }

  // =========================================================
  // SIGNUP USER
  // =========================================================
  static Future<Map<String, dynamic>> signupNewUser(String phone) async {
    print("🆕 [SIGNUP USER] Phone → $phone");

    final response = await http.post(
      Uri.parse("$baseUrl/signup-new-user/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "Gtoken": "sddwdwdwdd",
        "password": "",
      }),
    );

    print("📥 SIGNUP RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      print("✅ SIGNUP SUCCESS → userId: ${data["existingUser"]["_id"]}");
      print("🔐 Signup hashOtp: ${data["otp"]}");

      return {
        "success": true,
        "userId": data["existingUser"]["_id"],
        "token": data["token"],
        "hashOtp": data["otp"],
      };
    }

    print("❌ SIGNUP FAILED");
    throw Exception(data["message"] ?? "Signup failed");
  }

  // =========================================================
  // SECOND LOGIN OTP FOR NEW USER
  // =========================================================
  static Future<Map<String, dynamic>> signupLoginOtp(String phone) async {
    print("📨 [SEND SECOND OTP] Phone → $phone");

    final response = await http.post(
      Uri.parse("$baseUrl/signup-login-otp/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone, "password": ""}),
    );

    print("📥 SECOND OTP RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      print("✅ SECOND OTP SUCCESS");
      print("🔐 hashOtp: ${data['otp']}");
      print("🔢 newOtp: ${data['newOtp']}");

      return {
        "success": true,
        "hashOtp": data["otp"],
        "otp": data["newOtp"],
        "token": data["token"],
        "userId": data["existingUser"]?["_id"], // SAFE HERE
        "newUser": data["newUser"] == true,

      };

    }

    throw Exception("Failed to send second OTP");
  }

  // =========================================================
  // USER PROFILE
  // =========================================================
  static Future<Map<String, dynamic>> getCurrentUser(String userId) async {
    print("👤 [FETCH PROFILE] userId → $userId");

    final response = await http.post(
      Uri.parse("$baseUrl/auth-user"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": userId}),
    );

    print("📥 PROFILE RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      print("✅ PROFILE LOADED");
      return data["existingUser"];
    }

    print("❌ PROFILE FAILED");
    throw Exception("User not found");
  }




  // ---------------- HOME LAYOUT ----------------
  static Future<HomeLayoutModel?> getHomeLayout() async {
    final res = await http.get(Uri.parse("$baseUrl/home-layout-data"));
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      return HomeLayoutModel.fromJson(jsonData["homeLayout"]);
    }
    return null;
  }

  // ---------------- HOSPITAL LIST ----------------
  static Future<List<HospitalModel>> getHospitals() async {
    final res = await http.get(
      Uri.parse("$baseUrl/all-hospital?state&city&department&page=1&limit=50"),
    );

    List<HospitalModel> list = [];
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      for (var item in jsonData["users"]) {
        list.add(HospitalModel.fromJson(item));
      }
    }
    return list;
  }

  // ---------------- DOCTOR LIST ----------------
  static Future<List<DoctorListModel>> getDoctors() async {
    final res = await http.get(
      Uri.parse("$baseUrl/all-vendors?state&city&department&page=1&limit=50"),
    );

    List<DoctorListModel> list = [];
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      for (var item in jsonData["users"]) {
        list.add(DoctorListModel.fromJson(item));
      }
    }
    return list;
  }




// =========================================================
// UPDATE USER PROFILE (PUT API)
// =========================================================
  static Future<bool> updateUser(String userId, Map<String, dynamic> body) async {
    print("✏️ [UPDATE USER] Updating → $userId");
    print("📤 Payload: $body");

    final response = await http.put(
      Uri.parse("$baseUrl/update-user-details/$userId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("📥 UPDATE RESPONSE (${response.statusCode}): ${response.body}");

    final data = jsonDecode(response.body);

    return data["success"] == true;
  }


  /// --------------------- HOME HEADER FETCH METHOD ---------------------
  static Future<List<dynamic>> fetchHomeHeader() async {
    try {
      final url = Uri.parse("$baseUrl/home-data");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["homeData"] != null && json["homeData"]["header"] != null) {
          return json["homeData"]["header"];
        } else {
          throw "No header found in response.";
        }
      } else {
        throw "Request failed: ${response.statusCode}";
      }

    } catch (e) {
      throw Exception("Home Header Exception: $e");
    }
  }
  // =========================================================
// UPDATE USER DETAILS (ADMIN PROFILE UPDATE)
// API: /admin/update-user-details/:id
// =========================================================
  static Future<bool> updateUserDetails(
      String userId,
      Map<String, dynamic> body,
      ) async {
    try {
      print("✏️ [ADMIN UPDATE USER]");
      print("👤 UserId → $userId");
      print("📤 Payload → $body");

      final response = await http.put(
        Uri.parse("$baseUrl/admin/update-user-details/$userId"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print(
          "📥 UPDATE RESPONSE (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["success"] == true;
      }

      return false;
    } catch (e) {
      print("❌ UPDATE USER ERROR → $e");
      return false;
    }
  }



}
