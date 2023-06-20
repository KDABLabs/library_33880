import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool expandAccounts = false;

  void setAccountsExpanded(bool expanded) {
    if (expandAccounts == expanded) {
      return;
    }

    expandAccounts = expanded;

    notifyListeners();
  }
}