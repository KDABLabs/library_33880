import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:html/dom.dart' as dom;

class Reservation {
  final String kind;
  final String title;
  static final formatter = intl.DateFormat('dd/MM/yyyy');

  const Reservation(
    this.kind,
    this.title,
  );

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'title': title,
    };
  }

  static List<Reservation>? parse(dom.Document document) {
    /*
      <div class="result">
          <div class="resultheader"><strong>Mes réservations en cours</strong> (total 0)</div>
          <table class="standtable">
              <colgroup>
                  <col style="width: 5%;"/>
                  <col style="width:85%;"/>
                  <col style="width: 5%;"/>
                  <col style="width: 5%;"/>
              </colgroup>
              <tr>
                  <td colspan='4'>Aucune réservation</td>
              </tr>
          </table>
      </div>
    */

    if (!document.hasContent()) {
      debugPrint('Reservation::parse: Invalid document to parse');
      return null;
    }

    final result = document.getElementsByClassName('result').elementAtOrNull(1);

    if (result == null) {
      debugPrint('Reservation::parse: Can not locate result element');
      return null;
    }

    final resultHeader =
        result.getElementsByClassName('resultheader').firstOrNull;

    if (resultHeader == null) {
      debugPrint('Reservation::parse: Can not locate resultHeader element');
      return null;
    }

    if (!resultHeader.text.trim().startsWith('Mes réservations en cours')) {
      debugPrint('Reservation::parse: Invalid resultHeader element');
      return null;
    }

    final table = result.getElementsByClassName('standtable').firstOrNull;

    if (table == null) {
      debugPrint('Reservation::parse: Can not locate table element');
      return null;
    }

    final columns = table.getElementsByTagName('colgroup').firstOrNull;

    if (columns == null) {
      debugPrint('Reservation::parse: Can not locate table columns element');
      return null;
    }

    if (columns.children.length != 4) {
      debugPrint('Reservation::parse: Unexpected table columns length');
      return null;
    }

    final rows = table.getElementsByTagName('tr');
    final reservations = List<Reservation>.empty(growable: true);

    // Skip first row - it's header
    for (int i = 1; i < rows.length; ++i) {
      final cols = rows[i].children;
      reservations.add(Reservation(
        cols[0].text,
        cols[1].text,
        // formatter.parse(cols[2].text),
        // formatter.parse(cols[3].text),
      ));
    }

    if (kDebugMode && reservations.isEmpty) {
      reservations.add(const Reservation(
        'L',
        'Le Dernier Des Mohicans',
      ));

      reservations.add(const Reservation(
        'A',
        'E-Type - Greatests Hits',
      ));

      reservations.add(const Reservation(
        'V',
        'Rocky I',
      ));
    }

    return reservations;
  }
}
