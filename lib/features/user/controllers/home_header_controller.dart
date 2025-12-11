import 'package:appointment_app/features/user/services/user_api_service.dart';
import 'package:flutter/foundation.dart';


class HomeHeaderController extends ChangeNotifier {
  bool isLoading = false;
  List<dynamic> headerList = [];
  String? errorMessage;

  /// Load Header from API
  Future<void> loadHeaders() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await UserApiService.fetchHomeHeader();
      headerList = data;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      headerList = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
