
 import 'package:http/http.dart' as http;
import 'dart:convert';
 class ApiService{

   static const String baseUrl = "https://hospitalquee.onrender.com";


   static Future<List<dynamic>> getHospitalUsers(String hospitalId) async {
     try {
       final url = Uri.parse(
         "$baseUrl/admin/all-user?page=1&limit=100&userId=$hospitalId",
       );

       final response = await http.get(
         url,
         headers: {
           'Content-Type': 'application/json',
         },
       );

       if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         if (data['success'] == true) {
           return data['users'] as List<dynamic>;
         } else {
           throw Exception(data['message'] ?? "Failed to fetch users");
         }
       } else {
         throw Exception("Server error: ${response.statusCode}");
       }
     } catch (e) {
       print("API Error (getHospitalUsers): $e");
       rethrow;
     }
   }
 }