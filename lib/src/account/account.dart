import 'dart:ui';

class Account {
  const Account(this.displayName, this.login, this.password, this.color);

  final String displayName;
  final String login;
  final String password;
  final Color color;
}

typedef Accounts = List<Account>;
