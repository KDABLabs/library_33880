import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:html/dom.dart' as dom;

class Loan {
  const Loan(
    this.kind,
    this.title,
    this.returnDateTime,
    this.loanDateTime,
  );

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'title': title,
      'returnDateTime': returnDateTime,
      'loanDateTime': loanDateTime,
    };
  }

  static List<Loan>? parse(dom.Document document) {
    /*
      <div class="result">
          <div class="resultheader"><strong>Mes prêts</strong> (total 2)
              <a class="btnav" style="float: right;margin:0px;color:blue;font-size: 1.2em;padding: 10px 50px;" href="extend">Prolonger</a>
          </div>
          <table class="standtable">
              <colgroup>
                  <col style="width: 10%;"/>
                  <col style="width: 70%;"/>
                  <col style="width: 10%;"/>
                  <col style="width: 10%;"/>
              </colgroup>
              <tr>
                  <th style="text-align:center;">Support</th>
                  <th>Titre</th>
                  <th style="text-align:center;white-space:nowrap;">Retour prévu</th>
                  <th style="text-align:center;">Date prêt</th>
              </tr>
              <tr>
                  <td style='text-align:center;vertical-align:middle;font-size:small;'>L</td>
                  <td style='white-space:normal;'>Animal Jack. 5, Revoir un printemps / Kid Toussaint. - Dupuis, 2021 <br><span style='color:red; font-size: 12px'></span></td>
                  <td style='text-align:center;vertical-align:middle;font-size:small;'>12/07/2023</td>
                  <td style='text-align:center;vertical-align:middle;font-size:small;'>12/06/2023</td>
              </tr>
              <tr>
                  <td style='text-align:center;vertical-align:middle;font-size:small;'>L</td>
                  <td style='white-space:normal;'>Vie (La). - Larousse <br><span style='color:red; font-size: 12px'></span></td>
                  <td style='text-align:center;vertical-align:middle;font-size:small;'>12/07/2023</td>
                  <td style='text-align:center;vertical-align:middle;font-size:small;'>12/06/2023</td>
              </tr>
          </table>
      </div>
    */

    if (!document.hasContent()) {
      debugPrint('Loan::parse: Invalid document to parse');
      return null;
    }

    final result = document.getElementsByClassName('result').elementAtOrNull(2);

    if (result == null) {
      debugPrint('Loan::parse: Can not locate result element');
      return null;
    }

    final resultHeader =
        result.getElementsByClassName('resultheader').firstOrNull;

    if (resultHeader == null) {
      debugPrint('Loan::parse: Can not locate resultHeader element');
      return null;
    }

    if (!resultHeader.text.trim().startsWith('Mes prêts')) {
      debugPrint('Loan::parse: Invalid resultHeader element');
      return null;
    }

    final table = result.getElementsByClassName('standtable').firstOrNull;

    if (table == null) {
      debugPrint('Loan::parse: Can not locate table element');
      return null;
    }

    final columns = table.getElementsByTagName('colgroup').firstOrNull;

    if (columns == null) {
      debugPrint('Loan::parse: Can not locate table columns element');
      return null;
    }

    if (columns.children.length != 4) {
      debugPrint('Loan::parse: Unexpected table columns length');
      return null;
    }

    final rows = table.getElementsByTagName('tr');
    final formatter = intl.DateFormat('dd/MM/yyyy');
    final List<Loan> loans = List<Loan>.empty(growable: true);

    // Skip first row - it's header
    for (int i = 1; i < rows.length; ++i) {
      final cols = rows[i].children;
      loans.add(Loan(
        cols[0].text,
        cols[1].text,
        formatter.parse(cols[2].text),
        formatter.parse(cols[3].text),
      ));
    }

    if (kDebugMode && loans.isEmpty) {
      loans.add(Loan(
        'L',
        'Les 3 Mousquetaires',
        DateTime.now(),
        DateTime.now(),
      ));

      loans.add(Loan(
        'A',
        'Masterboy - Generation Of Love',
        DateTime.now(),
        DateTime.now(),
      ));

      loans.add(Loan(
        'V',
        'Jungle Book',
        DateTime.now(),
        DateTime.now(),
      ));
    }

    return loans;
  }

  final String kind;
  final String title;
  final DateTime returnDateTime;
  final DateTime loanDateTime;
}
