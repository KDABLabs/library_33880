import 'dart:ui';

class Account {
  final String displayName;
  final String login;
  final String password;
  final Color color;
  
  const Account(this.displayName, this.login, this.password, this.color);
}

typedef Accounts = List<Account>;
