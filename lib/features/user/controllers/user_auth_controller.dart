import '../services/user_api_service.dart';
import '../../../shared/utils/preferences.dart';

class PatientAuthController {
  static String? _phone;
  static String? _hashOtp;
  static String? _tempUserId;
  static bool _isNewUser = false;

  // =========================================================
  // STEP 1 → SEND OTP
  // =========================================================
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    print("📩 SEND OTP → $phone");

    final result = await UserApiService.signupLoginOtp(phone);

    _phone = phone;
    _hashOtp = result["hashOtp"];
    _isNewUser = (result["newUser"] == true);

    if (!_isNewUser) {
      _tempUserId = result["userId"];
    }

    return result;
  }

  // =========================================================
  // STEP 2 → VERIFY FIRST OTP
  // =========================================================
  static Future<dynamic> verifyOtp(String otp) async {
    print("🔐 VERIFY FIRST OTP → $otp");

    final ok = await UserApiService.verifyOtp(_hashOtp!, otp);
    if (!ok) throw Exception("Invalid OTP");

    // ------------------------------
    // EXISTING USER LOGIN
    // ------------------------------
    if (!_isNewUser) {
      print("👤 EXISTING USER LOGIN SUCCESS");

      await PrefUtils.saveUser(_tempUserId!, "patient");

      final apiProfile = await UserApiService.getCurrentUser(_tempUserId!);

      // 🔥 FIX: Save structured data
      await PrefUtils.saveUserData({
        "userId": apiProfile["_id"],
        "name": apiProfile["username"],
        "phone": apiProfile["phone"],
        "profile": apiProfile["profile"],
        "email": apiProfile["email"],
      });

      _clear();
      return true;
    }

    // ------------------------------
    // NEW USER SIGNUP
    // ------------------------------
    print("🆕 NEW USER → SIGNUP…");

    final signupRes = await UserApiService.signupNewUser(_phone!);
    final newUserId = signupRes["userId"];

    await PrefUtils.saveUser(newUserId, "patient");

    print("🆕 SIGNUP DONE → $newUserId");

    // Now send 2nd OTP
    final loginOtp = await UserApiService.signupLoginOtp(_phone!);
    _hashOtp = loginOtp["hashOtp"];

    return "SECOND_OTP";
  }

  // =========================================================
  // STEP 3 → VERIFY SECOND OTP (NEW USER ONLY)
  // =========================================================
  static Future<bool> verifySecondOtp(String otp) async {
    print("🔐 VERIFY SECOND OTP → $otp");

    final ok = await UserApiService.verifyOtp(_hashOtp!, otp);
    if (!ok) throw Exception("Invalid OTP");

    final userId = await PrefUtils.getUserId();

    final apiProfile = await UserApiService.getCurrentUser(userId!);

    // 🔥 FIX: Save structured user object
    await PrefUtils.saveUserData({
      "userId": apiProfile["_id"],
      "name": apiProfile["username"],
      "phone": apiProfile["phone"],
      "profile": apiProfile["profile"],
      "email": apiProfile["email"],
    });

    print("🎉 NEW USER LOGIN SUCCESS");

    _clear();
    return true;
  }

  static void _clear() {
    _phone = null;
    _hashOtp = null;
    _tempUserId = null;
    _isNewUser = false;
  }
}
