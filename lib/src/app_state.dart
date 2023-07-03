import 'package:flutter/material.dart';

import 'account/account.dart';
import 'account/session.dart';

class AppState extends ChangeNotifier {
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
      session?.getBooks().then(
            (value) => notifyListeners(),
          );
    } else {
      session = null;
    }

    notifyListeners();
  }
}