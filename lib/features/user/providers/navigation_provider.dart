import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int pageIndex = 0;

  void changeTab(int index) {
    pageIndex = index;
    notifyListeners();
  }

  void navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context); // Drawer close
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
