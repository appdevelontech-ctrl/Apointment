import 'package:flutter/material.dart';

import '../models/home_layout_model.dart';
import '../models/hospital_model.dart';
import '../models/doctor_model.dart';
import '../services/user_api_service.dart';


class HomeController with ChangeNotifier {
  bool isLoading = false;

  HomeLayoutModel? homeLayout;
  List<HospitalModel> hospitals = [];
  List<DoctorListModel> doctors = [];

  Future<void> loadHomeData() async {
    isLoading = true;
    notifyListeners();

    homeLayout = await UserApiService.getHomeLayout();
    hospitals = await UserApiService.getHospitals();
    doctors = await UserApiService.getDoctors();

    isLoading = false;
    notifyListeners();
  }
}
