import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../account/account.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  Future<ThemeMode> themeMode() async {
    final prefs = await SharedPreferences.getInstance();
    int? theme = prefs.getInt('theme');
    return theme != null ? ThemeMode.values[theme] : ThemeMode.system;
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('theme', theme.index);
  }

  Future<Accounts> accounts() async {
    final prefs = await SharedPreferences.getInstance();
    Accounts accounts = Accounts.empty(growable: true);

    if (prefs.containsKey('accounts/count')) {
      final int count = prefs.getInt('accounts/count')!;

      for (int i = 0; i < count; ++i) {
        String? displayName;
        String? login;
        String? password;
        int? color;

        displayName = prefs.getString('accounts/$i/displayName');
        login = prefs.getString('accounts/$i/login');
        password = prefs.getString('accounts/$i/password');
        color = prefs.getInt('accounts/$i/color');

        assert(login!.isNotEmpty && password!.isNotEmpty);

        accounts.add(Account(
          displayName ?? login!,
          login!,
          password!,
          Color(color ?? 0),
        ));
      }
    }

    return accounts;
  }

  Future<void> updateAccounts(Accounts accounts) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('accounts');

    prefs.setInt('accounts/count', accounts.length);

    for (int i = 0; i < accounts.length; ++i) {
      final account = accounts[i];

      prefs.setString('accounts/$i/displayName', account.displayName);
      prefs.setString('accounts/$i/login', account.login);
      prefs.setString('accounts/$i/password', account.password);
      prefs.setInt('accounts/$i/color', account.color.value);
    }
  }

  Future<int> currentAccountIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int? index = prefs.getInt('currentAccountIndex');
    return index ?? -1;
  }

  Future<void> updateCurrentAccountIndex(int currentAccountIndex) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('currentAccountIndex', currentAccountIndex);
  }
}
