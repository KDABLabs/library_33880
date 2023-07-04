import 'package:flutter/material.dart';

import 'account/account.dart';
import 'account/session.dart';

class AppState extends ChangeNotifier {
  AppState({Account? account}) {
    setCurrentAccount(account);
  }

  bool expandAccounts = false;
  Session? session;

  void setAccountsExpanded(bool expanded) {
    if (expandAccounts == expanded) {
      return;
    }

    expandAccounts = expanded;

    notifyListeners();
  }

  void setCurrentAccount(Account? account) {
    if (account != null) {
      session = Session(account);
      session?.getData().then(
            (value) => notifyListeners(),
          );
    } else {
      session = null;
    }

    notifyListeners();
  }
}
