import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;

class Result {
  final String id;
  final String title;
  final List<String> authors;
  final String editor;
  final String? summary;
  final int availableCopies;
  final Uri imageUrl;
  final List<String> tags;

  const Result(
    this.id,
    this.title,
    this.authors,
    this.editor,
    this.summary,
    this.availableCopies,
    this.imageUrl,
    this.tags,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'editor': editor,
      'summary': summary,
      'availableCopies': availableCopies,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }

  static Result empty() {
    return Result(
      '',
      'Not available',
      [],
      '',
      null,
      0,
      Uri(),
      [],
    );
  }

  static List<Result>? parse(dom.Document document, useFakeItems) {
    /*
      <div class="result">
          <div class="resultheader">
              <div class="resultnbr" style="float: left;">
                  <strong>Résultats:</strong> 3 / Réponses 1 à 3 sur 3
              </div>
              <div class="itemsdisplay">
                  <label>
                      <strong>Affichage :</strong>
                  </label>
                  <a href="/cassioweb/index.php/Search/index?kindOfDisplayResuts=list">
                      <i style="color: black" title="liste" class="fa fa-list-alt "></i>
                  </a>
                  <a href="/cassioweb/index.php/Search/index?kindOfDisplayResuts=complete">
                      <i title="complet" class="fa fa-th-list " style="color: black"></i>
                  </a>
                  <a href="/cassioweb/index.php/Search/index?kindOfDisplayResuts=vignette">
                      <i title="vignette" class="fa fa-th " style="color: black"></i>
                  </a>
              </div>
          </div>
          <div class="nextprevnav">
              <ul class="nextprev">
                  <li>
                      <div class="unselect">&lt;&lt;</div>
                  </li>
                  <li>
                      <div class="unselect">&lt;</div>
                  </li>
                  <li>
                      <a href="search/index?p=1&num_config=27&kindOfDisplayResuts=complete " class="selected">1</a>
                  </li>
                  <li>
                      <div class="unselect">&gt;</div>
                  </li>
                  <li>
                      <div class="unselect">&gt;&gt;</div>
                  </li>
                  <select id="num_config" name="num_config">
                      <option value="9">9</option>
                      <option value="18">18</option>
                      <option value="27" selected="selected">27</option>
                  </select> par page
              </ul>
              <div class="outiltri">
                  <span class="intro">trier par&nbsp;</span>
                  <div class="customselect">
                      <select id="sort_results" class="select">
                          <option value='info/sortResultsByTitle'>Titre</option>
                          <option value='info/sortResultsByAuthors'>Auteurs</option>
                          <option value='info/sortResultsByEditors'>Editeurs</option>
                          <option value='info/sortResultsByYear'>Année</option>
                      </select>
                  </div>
              </div>
          </div>
          <table class="standtable tablelist" id="example">
              <colgroup>
                  <col style="width: 10px;" />
                  <col style="width: 30px;" />
                  <col />
              </colgroup>
              <tr style='font-size:9 font-family: helvetica, arial, verdana, sans-serif'>
                  <td>
                      <input type='checkbox' class='selnotice' value='63289' />
                  </td>
                  <td id="linelink">
                      <a href="search/notice/63289">
                          <img style="" width="100" height="150" src='https://products-images.di-static.com/image/orb-50553929030c5264c4e5c2f4a5c023f2/9782747032780-120x160-1.jpg' />
                      </a>
                  <td class='list'>
                      <div class='livre'></div>
                  </td>
                  <td id="linelink">livre - Roman Enfant <br>
                      <a href='search/notice/63289?lieu=F'>
                          <strong>
                              <font size='2'>Titre :</font>
                          </strong>
                          <span>Comment cuisiner et dévorer les enfants</span>
                      </a>
                      <a href='search/notice/63289?lieu=F'>
                          <strong>
                              <font size='2'>Auteur :</font>
                          </strong> McGowan Keith ,Huard Alexandra ,Suhard-guié Karine </a>
                      <a href='search/notice/63289?lieu=F'>
                          <strong>
                              <font size='2'>Editeur :</font>
                          </strong> Bayard jeunesse ,impr. 2012 </a>
                      <a href='search/notice/63289?lieu=F'></a>
                      <div class='foot-compete'>
                          <div class='num-copies' style='color:red;'>Aucun exemplaire disponible</div>
                      </div>
              </tr>
          </table>
      </div>
    */

    if (!document.hasContent()) {
      debugPrint('Result::parse: Invalid document to parse');
      return null;
    }

    final result = document.getElementsByClassName('result').firstOrNull;

    if (result == null) {
      debugPrint('Result::parse: Can not locate result element');
      return null;
    }

    final resultHeader =
        result.getElementsByClassName('resultheader').firstOrNull;

    if (resultHeader == null) {
      debugPrint('Result::parse: Can not locate resultHeader element');
      return null;
    }

    if (!resultHeader.text.trim().startsWith('Résultats:')) {
      debugPrint('Result::parse: Invalid resultHeader element');
      return null;
    }

    final table = result.getElementsByClassName('standtable').firstOrNull;

    if (table == null) {
      debugPrint('Result::parse: Can not locate table element');
      return null;
    }

    final columns = table.getElementsByTagName('colgroup').firstOrNull;

    if (columns == null) {
      debugPrint('Result::parse: Can not locate table columns element');
      return null;
    }

    if (columns.children.length != 3) {
      debugPrint('Result::parse: Unexpected table columns length');
      return null;
    }

    final rows = table.getElementsByTagName('tr');
    final List<Result> results = List<Result>.empty(growable: true);

    for (int i = 0; i < rows.length; ++i) {
      final metadata = () {
        final cols = rows[i].getElementsByTagName('td'); // td
        assert(cols.length == 4);
        final idElement = cols[0].getElementsByTagName('input').firstOrNull;
        final imageElement = cols[1].getElementsByTagName('img').firstOrNull;
        final copiesElement =
            cols[3].getElementsByClassName('num-copies').firstOrNull;
        final links = cols[3].getElementsByTagName('a');

        String extractByKey(String key) {
          dom.Element match;

          try {
            match = links
                .firstWhere((element) => element.text.trim().startsWith(key));
            return (match.text.split(':').lastOrNull?.trim() ?? '')
                .replaceAll('  ', ' ');
          } catch (e) {
            return '';
          }
        }

        List<String> splitString(String? string, String separator) {
          List<String> result = (string?.split(separator) ?? [])
              .map((e) => e.replaceAll('  ', ' ').trim())
              .toList();
          result.removeWhere((element) => element.isEmpty);
          return result;
        }

        return {
          'id': idElement?.attributes['value'] ?? '',
          'imageUrl': imageElement?.attributes['src'] ?? '',
          'tags': splitString(cols[3].firstChild?.text, '-'),
          'title': extractByKey('Titre :'),
          'authors': splitString(extractByKey('Auteur :'), ','),
          'editor': splitString(extractByKey('Editeur :'), ',')
              .join(', '), // fix comma on wrong side
          'summary': extractByKey('Résumé :'),
          'copies':
              int.tryParse(copiesElement?.text.split(' ').firstOrNull ?? '') ??
                  0,
        };
      }();

      results.add(Result(
        metadata['id'] as String,
        metadata['title'] as String,
        metadata['authors'] as List<String>,
        metadata['editor'] as String,
        metadata['summary'] as String?,
        metadata['copies'] as int,
        Uri.parse(metadata['imageUrl'] as String),
        metadata['tags'] as List<String>,
      ));
    }

    if (useFakeItems && results.isEmpty) {
      results.add(Result(
        '63289',
        'Comment cuisiner et dévorer les enfants',
        [
          'McGowan Keith',
          'Huard Alexandra',
          'Suhard-guié Karine',
        ],
        'Bayard jeunesse, impr. 2012',
        '',
        0,
        Uri.parse(
            'https://products-images.di-static.com/image/orb-50553929030c5264c4e5c2f4a5c023f2/9782747032780-120x160-1.jpg'),
        [
          'livre',
          'Roman Enfant',
        ],
      ));

      results.add(Result(
        '112545',
        'Comment cuisiner les lapins',
        [
          'Escoffier Michaël',
          'Gauthier Manon',
        ],
        'Kaléidoscope-l\'Ecole des loisirs, 12/2/2020',
        '',
        1,
        Uri.parse(
            'https://products-images.di-static.com/image/orb-50553929030c5264c4e5c2f4a5c023f2/9782378880132-120x160-1.jpg'),
        [
          'livre',
          'Album',
        ],
      ));

      results.add(Result(
        '68448',
        'Mes produits fumés',
        [
          'Guézille Caroline',
        ],
        'Rustica, 2010',
        'Mes produits fumésVous venez d\'acheter un lot de viande?Vous aimeriez fumer vous-même du saumon frais ou un poulet fermier?Mes produits fumés vous explique comment préparer....',
        1,
        Uri.parse(
            'https://products-images.di-static.com/image/orb-50553929030c5264c4e5c2f4a5c023f2/9782815300179-120x160-1.jpg'),
        [
          'livre',
          'Documentaire',
        ],
      ));
    }

    return results;
  }
}
