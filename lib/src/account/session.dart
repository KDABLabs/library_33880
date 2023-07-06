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

  Session(this.account, {Map<String, String>? cookies})
      : cookies = cookies ??
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

  Uri accountUri() {
    return Uri.https(apiHost(), 'cassioweb/index.php/account');
  }

  Future<http.Response> logIn() {
    return http.post(
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
  }

  Future<http.Response> logOut() {
    return http.get(
      loginUri(),
      headers: {
        'Cookies': cookiesAsString(),
      },
    );
  }

  Future<http.Response> status() {
    return http.get(
      accountUri(),
      headers: {
        'cookie': cookiesAsString(),
      },
    );
  }

  Future<bool> getData() async {
    // var data = await status();

    // if (data.statusCode == 200) {
    //   print('Get data from session');
    //   print(data.statusCode);
    //   print(data.reasonPhrase);
    //   print(data.headers);
    //   print(data.request);
    //   print(data.request?.contentLength);
    //   print(data.body);
    //   return data;
    // }

    var login = await logIn();

    if (login.statusCode != 302) {
      debugPrint('Can not log in');
      return false;
    }

    final session = Cookie.fromSetCookieValue(login.headers['set-cookie']!);

    if (session.name.isNotEmpty) {
      cookies[session.name] = session.value;

      debugPrint('Updated session');

      var data = await status();

      if (data.statusCode == 200) {
        debugPrint('Got status from account');

        final document = html.parse(data.body);

        if (!document.hasContent()) {
          debugPrint('Session::getData: Invalid document to parse');
          return false;
        }

        information = Information.parse(document);
        reservations = Reservation.parse(document);
        loans = Loan.parse(document);

        return information != null && reservations != null && loans != null;
      } else {
        debugPrint('Can not get account status');
      }
    }

    debugPrint('Can\'t get session');
    return false;
  }
}
