
class Account {
  const Account(this.displayName, this.login, this.password);

  final String displayName;
  final String login;
  final String password;
}

typedef Accounts = List<Account>;
