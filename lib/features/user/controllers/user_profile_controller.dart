// import 'package:flutter/material.dart';
// import '../models/user.dart';
// import '../services/user_api_service.dart';
//
// class UserProfileController extends ChangeNotifier {
//   UserModel? user;
//   bool isLoading = false;
//
//   // LOAD PROFILE
//   Future<void> loadUserProfile(String userId) async {
//     isLoading = true;
//     notifyListeners();
//
//     final data = await UserApiService.getCurrentUser(userId);
//     user = UserModel.fromJson(data);
//
//     isLoading = false;
//     notifyListeners();
//   }
//
//   // UPDATE PROFILE (MODEL-MATCHED FIXED VERSION)
//   Future<bool> updateUserProfile(String userId, Map<String, dynamic> updated) async {
//     if (user == null) return false;
//
//     isLoading = true;
//     notifyListeners();
//
//     // 🔥 BODY MUST MATCH UserModel EXACTLY
//     final body = {
//       "phone": updated["phone"] ?? user!.phone,
//       "about": updated["about"] ?? user!.about,
//       "company": updated["company"] ?? user!.company,
//       "profile": user!.profile,
//
//       // LIST FIELDS (cannot be null!)
//       "department": user!.department,
//       "nurse": user!.nurse,
//       "calls": user!.calls,
//
//       // STRING FIELDS
//       "Doc1": user!.doc1,
//       "Doc2": user!.doc2,
//       "Doc3": user!.doc3,
//
//       // HEALTH FIELDS
//       "pHealthHistory": user!.pHealthHistory,
//       "cHealthStatus": user!.cHealthStatus,
//
//       // MAP FIELDS (empty allowed, null NOT allowed)
//       "schedule": user!.schedule,
//       "stats": user!.stats,
//
//       // OTHER FIELDS REQUIRED BY BACKEND
//       "type": user!.type,
//       "empType": user!.empType,
//       "verified": user!.verified,
//       "wallet": user!.wallet,
//     };
//
//     print("📤 FINAL UPDATE BODY → $body");
//
//     final ok = await UserApiService.updateUserDetails(userId, body);
//
//     if (ok) {
//       await loadUserProfile(userId); // refresh
//     }
//
//     isLoading = false;
//     notifyListeners();
//
//     return ok;
//   }
// }
