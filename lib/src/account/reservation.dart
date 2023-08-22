import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:html/dom.dart' as dom;

import '../utils.dart';

class Reservation {
  final DateTime reservationDateTime;
  final String title;
  final String availability;
  final String location;
  static final formatter = intl.DateFormat('dd/MM/yyyy');

  DateTime get experirationDateTime =>
      reservationDateTime.add(const Duration(days: 15));
  bool get isLate => DateTime.now().isAfter(experirationDateTime);
  String get formattedTitle => Utils.beautifyTitle(title);
  String get formattedAvailability => Utils.beautifyAvailability(availability);
  String get formattedExpirationDate => formatter.format(experirationDateTime);
  String get formattedReservationDate => formatter.format(reservationDateTime);

  const Reservation(
    this.reservationDateTime,
    this.title,
    this.availability,
    this.location,
  );

  Map<String, dynamic> toJson() {
    return {
      'reservationDateTime': reservationDateTime,
      'title': title,
      'availability': availability,
      'location': location,
    };
  }

  static List<Reservation>? parse(dom.Document document, useFakeItems) {
    /*
    <div class="result">
      <div class="resultheader"><strong>Mes réservations en cours</strong> (total 4)</div>
      <table class="standtable">
        <colgroup>
          <col style="width: 5%;">
          <col style="width:85%;">
          <col style="width: 5%;">
          <col style="width: 5%;">
        </colgroup>
        <tbody>
          <tr>   
            <th style="text-align:center;">Date </th>   
            <th style="text-align:center;">Titre</th>   
            <th style="white-space:nowrap;text-align:center;">Dispo &amp; Ret</th>   
            <th style="text-align:center;">Site</th>
          </tr>	               
          <tr>
            <td style="vertical-align:middle;text-align:center">22/08/2023</td>
            <td style="white-space:normal">Animal Jack. 1, Coeur de la forêt (Le) / Kid Toussaint. - Dupuis, 2019 </td>
            <td style="background-color:#dfffdf;vertical-align:middle;text-align:center;font-size:small;"><b>Non</b><br>En transit</td>
            <td style="vertical-align:middle;text-align:center">Latresne</td>
          </tr>
          <tr>
            <td style="vertical-align:middle;text-align:center">22/08/2023</td>
            <td style="white-space:normal">Animal Jack. 3, Planete du singe (La) / Kid Toussaint. - Dupuis, 2020 </td>
            <td style="background-color:#ffe4d0;vertical-align:middle;text-align:center;font-size:small;"><b>Non</b><br></td>
            <td style="vertical-align:middle;text-align:center">Saint-Caprais</td>
          </tr>
          <tr>
            <td style="vertical-align:middle;text-align:center">22/08/2023</td>
            <td style="white-space:normal">Animal Jack. 5, Revoir un printemps / Kid Toussaint. - Dupuis, 2021 </td>
            <td style="background-color:#ffe4d0;vertical-align:middle;text-align:center;font-size:small;"><b>Non</b><br></td>
            <td style="vertical-align:middle;text-align:center">Saint-Caprais</td>
          </tr>
          <tr>
            <td style="vertical-align:middle;text-align:center">22/08/2023</td>
            <td style="white-space:normal">Appel de la forêt (L') / Jack London. - Sarbacane, éditeur de création, DL 2015 </td>
            <td style="background-color:#dfffdf;vertical-align:middle;text-align:center;font-size:small;"><b>Non</b><br>En transit</td>
            <td style="vertical-align:middle;text-align:center">Latresne</td>
          </tr>	    
        </tbody>
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
        formatter.parse(cols[0].text),
        cols[1].text,
        _parseAvailability(cols[2]),
        cols[3].text,
      ));
    }

    if (useFakeItems && reservations.isEmpty) {
      reservations.add(Reservation(
        DateTime.now(),
        'Le Dernier Des Mohicans',
        'Non / En transit',
        'Latresne',
      ));

      reservations.add(Reservation(
        DateTime.now(),
        'E-Type - Greatests Hits',
        'Non',
        'Saint-Caprais',
      ));

      reservations.add(Reservation(
        DateTime.now(),
        'Rocky I',
        'Non / En transit',
        'Latresne',
      ));
    }

    return reservations;
  }

  static String _parseAvailability(dom.Element availability) {
    List<String> list = List<String>.empty(growable: true);

    for (dom.Node node in availability.nodes) {
      final String? text = node.text?.trim();

      if (text != null && text.isNotEmpty) {
        list.add(text);
      }
    }

    return list.join(' / ');
  }
}
