import 'dart:io';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import 'account.dart';
import 'information.dart';
import 'result.dart';
import 'loan.dart';
import 'reservation.dart';
import '../constants.dart';

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

  static String apiHost() {
    return 'bibliotheques.cdc-portesentredeuxmers.fr';
  }

  static Uri loginUri() {
    return Uri.https(apiHost(), 'cassioweb/account/login');
  }

  static Uri logoutUri() {
    return Uri.https(apiHost(), 'cassioweb/account/logout');
  }

  static Uri extendUri() {
    return Uri.https(apiHost(), 'cassioweb/extend');
  }

  static Uri findUri() {
    return Uri.https(apiHost(), '/cassioweb/search/find');
  }

  static Uri accountUri() {
    return Uri.https(apiHost(), 'cassioweb/index.php/account');
  }

  static Uri searchUri([Map<String, String>? query]) {
    return Uri.https(apiHost(), '/cassioweb/index.php/search/index', query);
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

  Future<bool> logIn() async {
    _clear(true);

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

    _clear(true);

    if (response.statusCode != 302) {
      debugPrint('LogOut: Can not log out');
      return false;
    }

    debugPrint('LogOut: Session updated');
    return true;
  }

  Future<bool> extend() async {
    _clear(false);

    final response = await http.get(
      extendUri(),
      headers: {
        'cookie': cookiesAsString(),
      },
    );

    if (response.statusCode == 302) {
      _parseAccountDocument(response.body);
      return true;
    }

    debugPrint('Extend: Can not extend loans');
    _parseAccountDocument(response.body);
    return false;
  }

  Future<bool> sync() async {
    _clear(false);

    final response = await http.get(
      accountUri(),
      headers: {
        'cookie': cookiesAsString(),
      },
    );

    if (response.statusCode == 200) {
      return _parseAccountDocument(response.body);
    }

    debugPrint('Sync: Can not get account status');
    return false;
  }

  Future<List<Result>?> resultsPage(
      {int page = 1, int resultsPerPage = 100}) async {
    final response = await http.get(
      searchUri(
        {
          'p': page.toString(),
          'num_config': resultsPerPage.toString(),
          'kindOfDisplayResuts': 'complete',
        },
      ),
      headers: {
        'cookie': cookiesAsString(),
      },
    );

    final document = html.parse(response.body);
    return Result.parse(document, false);
  }

  Future<List<Result>?> search(String search, int criteria) async {
    final response = await http.post(findUri(), headers: {
      'cookie': cookiesAsString(),
      'Content-Type': 'application/x-www-form-urlencoded',
    }, body: () {
      final String encodedFieldsName = Uri.encodeComponent('fields-0[]');
      final String encodedTermsName = Uri.encodeComponent('terms-0');
      final Iterable<EnumFlag> flags =
          criteria.getFlags(SearchCriterion.values);
      final List<String> data = () {
        List<String> result = flags
            .map((criteria) =>
                '$encodedFieldsName=${Uri.encodeComponent(criteria.name.toLowerCase())}')
            .toList();
        result.add('$encodedTermsName=${Uri.encodeComponent(search)}');
        return result;
      }();

      return data.join('&');
    }());

    if (response.statusCode != 302) {
      return Future<List<Result>?>.value();
    }

    return resultsPage();
  }

  // <option value='info/sortResultsByTitle'>Titre</option>
  // <option value='info/sortResultsByAuthors'>Auteurs</option>
  // <option value='info/sortResultsByEditors'>Editeurs</option>
  // <option value='info/sortResultsByYear'>Année</option>
  //
  // https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/info/getMediaWiki?name=McGowan%2C+Keith
  // https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/info/getTopRecommandations?notice=63289
  // https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/results/addToCart/63289
  // https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/results/getTotalCart

  void _clear(bool session) {
    if (session) {
      cookies.remove('session');
    }

    information = null;
    reservations = null;
    loans = null;
  }

  bool _parseAccountDocument(String body) {
    debugPrint('Account: Got account status');

    final document = html.parse(body);

    if (!document.hasContent()) {
      debugPrint('Account: Invalid document to parse');
      return false;
    }

    information = Information.parse(document);
    reservations = Reservation.parse(document, useFakeItems);
    loans = Loan.parse(document, useFakeItems);

    if (information != null && reservations != null && loans != null) {
      debugPrint('Account: Account synced');
      return true;
    }

    debugPrint('Account: Account sync failed');
    return false;
  }
}
