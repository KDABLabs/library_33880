import 'dart:ui';

class Account {
  String displayName;
  final String login;
  final String password;
  Color color;
  
  Account(
    this.displayName,
    this.login,
    this.password,
    this.color,
  );
}

typedef Accounts = List<Account>;
