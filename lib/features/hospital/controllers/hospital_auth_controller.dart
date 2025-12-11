
import '../../../shared/services/api_service.dart';
import '../../../shared/utils/preferences.dart';
import '../models/hospital_model.dart';

class HospitalAuthController {
  Future<Hospital?> login(String email, String password) async {
    final response = await ApiService.login(email, password);

    if (response['success'] == true) {
      final userJson = response['admin'] ?? response['existingUser'];
      if (userJson['empType'] == 2) {  // 2 = Hospital Admin
        final hospital = Hospital.fromJson(userJson);
        await PrefUtils.saveUser(hospital.id, "hospital");
        return hospital;
      }
    }
    return null;
  }

  Future<Hospital?> getCurrentHospital() async {
    final userId = await PrefUtils.getUserId();
    if (userId == null) return null;

    final response = await ApiService.authUser(userId);
    if (response['success'] == true) {
      final json = response['existingUser'];
      if (json['empType'] == 2) {
        return Hospital.fromJson(json);
      }
    }
    return null;
  }
}