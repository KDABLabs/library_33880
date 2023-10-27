import 'package:flutter/material.dart';

import 'settings_service.dart';
import '../account/account.dart';
import '../account/session.dart';

class SettingsController with ChangeNotifier {
  SettingsController(
    this._settingsService,
  );

  // Internals

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;
  late Accounts _accounts;
  late int _currentAccountIndex;

  // Not persisted in settings
  bool _accountExpanded = false;
  Session? _session;

  // Helpers

  // Retrieve all settings
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _accounts = await _settingsService.accounts();
    _currentAccountIndex = await _settingsService.currentAccountIndex();

    _setCurrentAccount(currentAccount);
  }

  Future<void> sync() async {
    if (_session != null) {
      _session = null;
      notifyListeners();
      _session = Session(currentAccount!);
      notifyListeners();
      _session!.logIn().then(
        (ok) {
          notifyListeners();
          if (ok) {
            session!.sync().then(
              (ok) {
                notifyListeners();
              },
            );
          }
        },
      );
    }
  }

  void extendLoans() {
    if (_session != null) {
      _session!.logIn().then(
        (ok) {
          if (ok) {
            _session!.extend().then(
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

  // Properties

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode theme) async {
    if (theme != _themeMode) {
      _themeMode = theme;

      notifyListeners();

      await _settingsService.setThemeMode(theme);
    }
  }

  Accounts get accounts => _accounts;

  Future<void> setAccounts(Accounts accounts) async {
    if (accounts != _accounts) {
      final String currentLogin = currentAccount?.login ?? '';

      _setAccountsAndCurrentAccount(accounts, currentLogin);
    }
  }

  int get currentAccountIndex => _currentAccountIndex;

  Future<void> setCurrentAccountIndex(int index) async {
    if (index >= -1 &&
        index < _accounts.length &&
        index != _currentAccountIndex) {
      _currentAccountIndex = index;

      _setCurrentAccount(currentAccount);

      await _settingsService.setCurrentAccountIndex(index);
    } else if (index != _currentAccountIndex) {
      debugPrint('Trying to set unexpected current account index: $index');
    }
  }

  Account? accountAt(int index) {
    if (index < 0 || index >= accounts.length) {
      if (index != -1) {
        debugPrint('Getting unexpected account index: $index');
      }

      return null;
    }

    return accounts[index];
  }

  Account? get currentAccount => accountAt(currentAccountIndex);

  Future<void> moveAccount(int oldIndex, int newIndex) async {
    RangeError.checkValidIndex(oldIndex, accounts, "from", accounts.length);
    RangeError.checkValidIndex(newIndex, accounts, "to", accounts.length + 1);

    final String currentLogin = currentAccount?.login ?? '';
    Accounts newAccounts = Accounts.from(accounts);
    Account account = newAccounts.removeAt(oldIndex);

    if (newIndex > oldIndex) {
      newAccounts.insert(newIndex - 1, account);
    } else {
      newAccounts.insert(newIndex, account);
    }

    _setAccountsAndCurrentAccount(newAccounts, currentLogin);
  }

  Future<void> addAccount(Account account) async {
    Accounts newAccounts = Accounts.from(accounts);

    newAccounts.add(account);

    _setAccountsAndCurrentAccount(newAccounts, account.login);
  }

  Future<void> removeAccount(int index) async {
    RangeError.checkValidIndex(index, accounts, "from", accounts.length);

    final String currentLogin = currentAccount?.login ?? '';
    Accounts newAccounts = Accounts.from(accounts);

    newAccounts.removeAt(index);

    _setAccountsAndCurrentAccount(newAccounts, currentLogin);
  }

  bool get accountExpanded => _accountExpanded;

  void setAccountExpanded(bool expanded) {
    if (_accountExpanded != expanded) {
      _accountExpanded = expanded;

      notifyListeners();
    }
  }

  Session? get session => _session;

  void _setCurrentAccount(Account? account) async {
    _accountExpanded = false;

    if (account != null) {
      if (_session?.account != account) {
        debugPrint(
            'Switching to ${account.displayName} from ${_session?.account.displayName}');
        _session = Session(account);
        sync();
      } else {
        notifyListeners();
      }
    } else {
      _session = null;
      notifyListeners();
    }
  }

  void _setAccountsAndCurrentAccount(Accounts accounts, String login) async {
    int index = accounts.indexWhere((element) => element.login == login);

    if (index == -1 && accounts.isNotEmpty) {
      index = 0;
    }

    _accounts = accounts;
    _currentAccountIndex = index;

    _setCurrentAccount(currentAccount);

    await _settingsService.setAccounts(accounts);
    await _settingsService.setCurrentAccountIndex(index);
  }
}
