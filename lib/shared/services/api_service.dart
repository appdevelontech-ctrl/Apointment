// shared/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://hospitalquee.onrender.com";

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user-login-all'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> authUser(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"id": id}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> doctorSignupWithFiles({
    required Map<String, dynamic> data,
    File? profile,
    File? doc1,
    File? doc2,
    File? doc3,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/signup-user-type'),
    );

    // FINAL FIX → SEND department[] fields PROPERLY
    data.forEach((key, value) {
      if (key == "department") {
        for (var id in value) {
          request.fields['department[]'] = id.toString();
        }
      } else {
        request.fields[key] = value.toString();
      }
    });

    // ADD FILES
    if (profile != null) {
      request.files.add(await http.MultipartFile.fromPath('profile', profile.path));
    }
    if (doc1 != null) {
      request.files.add(await http.MultipartFile.fromPath('Doc1', doc1.path));
    }
    if (doc2 != null) {
      request.files.add(await http.MultipartFile.fromPath('Doc2', doc2.path));
    }
    if (doc3 != null) {
      request.files.add(await http.MultipartFile.fromPath('Doc3', doc3.path));
    }

    final response = await request.send();
    final resStr = await response.stream.bytesToString();

    print("FINAL REQUEST RESPONSE: $resStr");

    return jsonDecode(resStr);
  }

  static Future<List<dynamic>> getAllZones() async {
    final response = await http.get(Uri.parse('$baseUrl/get-all-zones'));
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final zones = List<dynamic>.from(data['Zones']);
      zones.sort((a, b) => a['name'].compareTo(b['name']));
      return zones;
    }
    return [];
  }

  static Future<List<dynamic>> getAllDepartments() async {
    final response = await http.get(Uri.parse('$baseUrl/get-all-department'));
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final departments = List<dynamic>.from(data['Department']);
      departments.sort((a, b) => a['name'].compareTo(b['name']));
      return departments;
    }
    return [];
  }
}
