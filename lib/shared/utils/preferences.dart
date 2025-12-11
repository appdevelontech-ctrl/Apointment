// shared/utils/preferences.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrefUtils {
  static const String KEY_USER_ID = "user_id";
  static const String KEY_USER_TYPE = "user_type"; // "doctor", "hospital", "patient"
  static const String KEY_USER_DATA = "user_data"; // Full user object

  // Save User ID + Type
  static Future<void> saveUser(String id, String type) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(KEY_USER_ID, id);
    await pref.setString(KEY_USER_TYPE, type);
  }

  // Get User ID
  static Future<String?> getUserId() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(KEY_USER_ID);
  }

  // Get User Type
  static Future<String?> getUserType() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(KEY_USER_TYPE);
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final id = await getUserId();
    return id != null;
  }

  // NEW: Save Full User Data (Doctor/Hospital/Patient)
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(KEY_USER_DATA, jsonEncode(userData));
  }

  // NEW: Get Full User Data
  static Future<Map<String, dynamic>?> getUserData() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(KEY_USER_DATA);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      print("Error parsing user data: $e");
      return null;
    }
  }

  // Optional: Save Doctor Raw Data (Tere pehle wala use kar raha tha)
  static Future<void> saveDoctorRawData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("doctor_raw_data", jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getDoctorRawData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("doctor_raw_data");
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  // Full Logout (Sab Clear)
  static Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}