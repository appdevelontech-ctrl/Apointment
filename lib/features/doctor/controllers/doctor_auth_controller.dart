
import 'package:appointment_app/features/doctor/views/doctor_dashboard.dart';

import '../../../shared/services/api_service.dart';
import '../../../shared/utils/preferences.dart';
import '../models/doctor_model.dart';

class DoctorAuthController {

  Future<Doctor?> login(String email, String password) async {
    final response = await ApiService.login(email, password);

    if (response['success'] == true) {
      final userJson = response['admin'] ?? response['existingUser'];
      print("User Json is: $userJson");
      if (userJson['empType'] == 3) {

        final doctor = Doctor.fromJson(userJson);
        await PrefUtils.saveUser(doctor.id, "doctor");

        await PrefUtils.saveDoctorRawData({
          "existingUser": userJson
        });

        return doctor;
      }
    }
    return null;
  }

  Future<Doctor?> getCurrentDoctor() async {
    final userId = await PrefUtils.getUserId();
    if (userId == null) return null;

    final response = await ApiService.authUser(userId);
    if (response['success'] == true) {
      final json = response['existingUser'];
      if (json['empType'] == 3) {
        return Doctor.fromJson(json);
      }
    }
    return null;
  }
}