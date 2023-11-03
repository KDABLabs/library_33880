// ignore_for_file: constant_identifier_names

import 'package:enum_flag/enum_flag.dart';

class ConstantsRoutes {
  static const String root = '';
  static const String register = 'register';
  static const String settings = 'settings';
  static const String reservations = 'reservations';
  static const String reservationDetails = 'reservations/details';
  static const String loans = 'loans';
  static const String loanDetails = 'loans/details';
}

enum SearchCriterion with EnumFlag {
  All, // all
  Title, // title
  Author, // author
  Editor, // editor
  Subject, // subject
  Collection, // collection
  Serie, // serie
}

enum ResultView {
  Complete, // complete
  List, // list
  Vignette, // vignette
}
