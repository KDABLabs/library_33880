import 'package:flutter/material.dart';

import 'account/account.dart';
import 'account/session.dart';

class AppState extends ChangeNotifier {
  bool _expandAccounts = false;
  Session? _session;

  AppState({Account? account}) {
    setCurrentAccount(account);
  }

  bool get expandAccounts => _expandAccounts;
  Session? get session => _session;

  void setAccountsExpanded(bool expanded) {
    if (_expandAccounts == expanded) {
      return;
    }

    _expandAccounts = expanded;

    notifyListeners();
  }

  void setCurrentAccount(Account? account) {
    _expandAccounts = false;

    if (account != null) {
      _session = Session(account);
      sync();
    } else {
      _session = null;
    }

    notifyListeners();
  }

  void sync() {
    if (_session != null) {
      _session!.logIn().then(
        (ok) {
          if (ok) {
            session!.sync().then(
              (ok) {
                notifyListeners();
              },
            );
          } else {
            notifyListeners();
          }
        },
      );
    }
  }
}
