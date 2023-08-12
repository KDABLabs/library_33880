import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import 'account.dart';
import 'information.dart';
import 'loan.dart';
import 'reservation.dart';

class Session {
  final Account account;
  final Map<String, String> cookies;
  Information? information;
  List<Reservation>? reservations;
  List<Loan>? loans;
  static const bool useFakeItems = false; //kDebugMode;

  Session(
    this.account, {
    Map<String, String>? cookies,
  }) : cookies = cookies ??
            {
              'cookielawinfo-checkbox-necessary': 'yes',
              'cookielawinfo-checkbox-non-necessary': 'no',
              'viewed_cookie_policy': 'yes'
            };

  String apiHost() {
    return 'bibliotheques.cdc-portesentredeuxmers.fr';
  }

  String cookiesAsString() {
    StringBuffer result = StringBuffer();

    bool first = true;

    cookies.forEach((key, value) {
      if (!first) {
        result.write('; ');
      }

      first = false;

      result.write('$key=$value');
    });

    return result.toString();
  }

  Uri loginUri() {
    return Uri.https(apiHost(), 'cassioweb/account/login');
  }

  Uri logoutUri() {
    return Uri.https(apiHost(), 'cassioweb/account/logout');
  }

  Uri extendUri() {
    return Uri.https(apiHost(), 'cassioweb/extend');
  }

  Uri accountUri() {
    return Uri.https(apiHost(), 'cassioweb/index.php/account');
  }

  Future<bool> logIn() async {
    final response = await http.post(
      loginUri(),
      headers: {
        'cookie': cookiesAsString(),
      },
      body: {
        'login': account.login,
        'passwd': account.password,
        'submit': 'valider',
      },
    );

    if (response.statusCode != 302) {
      debugPrint('LogIn: Can not log in');
      return false;
    }

    if (!response.headers.containsKey('set-cookie')) {
      debugPrint('LogIn: Session did not changed');
      return true;
    }

    final session = Cookie.fromSetCookieValue(response.headers['set-cookie']!);

    if (session.name.isNotEmpty) {
      cookies[session.name] = session.value;

      debugPrint('LogIn: Session updated');
      return true;
    }

    debugPrint('LogIn: Can\'t update session');
    return false;
  }

  Future<bool> logOut() async {
    final response = await http.get(
      logoutUri(),
      headers: {
        'cookie': cookiesAsString(),
      },
    );

    if (response.statusCode != 302) {
      debugPrint('LogOut: Can not log out');
      return false;
    }

    cookies.remove('session');
    information = null;
    reservations = null;
    loans = null;

    debugPrint('LogOut: Session updated');
    return true;
  }

  Future<bool> extend() async {
    final response = await http.get(
      extendUri(),
      headers: {
        'cookie': cookiesAsString(),
      },
    );

    if (response.statusCode == 302) {
      debugPrint('Extend: Loans extended');
      return true;
    }

    debugPrint('Extend: Can not extend loans');
    return false;
  }

  Future<bool> sync() async {
    final response = await http.get(
      accountUri(),
      headers: {
        'cookie': cookiesAsString(),
      },
    );

    if (response.statusCode == 200) {
      debugPrint('Sync: Got account status');

      final document = html.parse(response.body);

      if (!document.hasContent()) {
        debugPrint('Sync: Invalid document to parse');
        return false;
      }

      information = Information.parse(document);
      reservations = Reservation.parse(document, useFakeItems);
      loans = Loan.parse(document, useFakeItems);

      if (information != null && reservations != null && loans != null) {
        debugPrint('Sync: Account synced');
        return true;
      }

      debugPrint('Sync: Account sync failed');
      return false;
    }

    debugPrint('Sync: Can not get account status');
    return false;
  }
}
