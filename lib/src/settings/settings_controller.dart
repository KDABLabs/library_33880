import 'package:flutter/material.dart';

import 'settings_service.dart';
import '../account/account.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(
    this._settingsService,
  );

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;
  late Accounts _accounts;
  late int _currentAccountIndex;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;
  Accounts get accounts => _accounts;
  int get currentAccountIndex => _currentAccountIndex;
  Account? get currentAccount =>
      currentAccountIndex < 0 || currentAccountIndex >= accounts.length
          ? null
          : accounts[currentAccountIndex];

  Account? accountAt(int index) =>
      index < 0 || index >= accounts.length ? null : accounts[index];

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _accounts = await _settingsService.accounts();
    _currentAccountIndex = await _settingsService.currentAccountIndex();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateAccounts(Accounts? newAccounts) async {
    if (newAccounts == null) return;

    if (newAccounts == _accounts) return;

    _accounts = newAccounts;

    notifyListeners();

    await _settingsService.updateAccounts(newAccounts);
  }

  Future<void> updateCurrentAccountIndex(int newCurrentAccountIndex) async {
    if (newCurrentAccountIndex < -1 ||
        newCurrentAccountIndex >= accounts.length) return;

    if (newCurrentAccountIndex == _currentAccountIndex) return;

    _currentAccountIndex = newCurrentAccountIndex;

    notifyListeners();

    await _settingsService.updateCurrentAccountIndex(newCurrentAccountIndex);
  }

  Future<void> moveAccount(int oldIndex, int newIndex) async {
    RangeError.checkValidIndex(oldIndex, accounts, "from", accounts.length);
    RangeError.checkValidIndex(newIndex, accounts, "to", accounts.length + 1);

    Accounts newAccounts = Accounts.from(accounts);
    Account account = newAccounts.removeAt(oldIndex);
    final currentLogin = currentAccount?.login ?? '';

    if (newIndex > oldIndex) {
      newAccounts.insert(newIndex - 1, account);
    } else {
      newAccounts.insert(newIndex, account);
    }

    final int currentIndex =
        newAccounts.indexWhere((element) => element.login == currentLogin);

    await updateAccounts(newAccounts);
    return updateCurrentAccountIndex(currentIndex);
  }
}
