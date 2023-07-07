import 'package:intl/intl.dart' as intl;
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';

class Information {
  final String cardNumber;
  final DateTime registrationDateTime;
  final DateTime renewDateTime;
  final String address;
  final int zipCode;
  final String city;
  final String phoneNumber;
  final String email;
  static final formatter = intl.DateFormat('dd / MM / yyyy');

  const Information(
    this.cardNumber,
    this.registrationDateTime,
    this.renewDateTime,
    this.address,
    this.zipCode,
    this.city,
    this.phoneNumber,
    this.email,
  );

  String formattedRegistrationDate() {
    return formatter.format(registrationDateTime);
  }

  String formattedRenewDate() {
    return formatter.format(renewDateTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'registrationDateTime': registrationDateTime,
      'renewDateTime': renewDateTime,
      'address': address,
      'zipCode': zipCode,
      'city': city,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  static Information empty() {
    return Information(
      '',
      DateTime.now(),
      DateTime.now(),
      '',
      0,
      '',
      '',
      '',
    );
  }

  static Information? parse(dom.Document document) {
    /*
      <div class="result infocompte">
          <div class="resultheader"><strong>Mes informations</strong> </div>
          <ul class="labellist">
              <li><label>Carte no</label>00000000SCXYZA&#160;</li>
              <li><label>Date inscription</label>12 / 10 / 2022&#160;</li>
              <li><label>Date renouvellement</label>11 / 10 / 2023&#160;</li>
              <li><label>Adresse</label>xyz&#160;</li>
              <li><label>Code postal</label>33880&#160;</li>
              <li><label>Ville</label>SAINT CAPRAIS DE BORDEAUX&#160;</li>
              <li><label>Téléphone</label>06.00.00.00.00&#160;</li>
              <li><label>Email</label>xyz@gmail.com&#160;</li>
          </ul>
      </div>
    */

    if (!document.hasContent()) {
      debugPrint('Information::parse: Invalid document to parse');
      return null;
    }

    final infoCompte =
        document.getElementsByClassName('result infocompte').firstOrNull;

    if (infoCompte == null) {
      debugPrint('Information::parse: Can not locate infocompte element');
      return null;
    }

    final resultHeader =
        infoCompte.getElementsByClassName('resultheader').firstOrNull;

    if (resultHeader == null) {
      debugPrint('Information::parse: Can not locate resultHeader element');
      return null;
    }

    if (resultHeader.text.trim() != 'Mes informations') {
      debugPrint('Information::parse: Invalid resultHeader element');
      return null;
    }

    final infoList = infoCompte.getElementsByClassName('labellist').firstOrNull;

    if (infoList == null) {
      debugPrint('Information::parse: Can not locate labellist element');
      return null;
    }

    if (infoList.children.length != 8) {
      debugPrint('Information::parse: Unexpected labellist children length');
      return null;
    }

    return Information(
      infoList.children[0].nodes[1].text!,
      formatter.parse(infoList.children[1].nodes[1].text!),
      formatter.parse(infoList.children[2].nodes[1].text!),
      infoList.children[3].nodes[1].text!,
      int.parse(infoList.children[4].nodes[1].text!),
      infoList.children[5].nodes[1].text!,
      infoList.children[6].nodes[1].text!,
      infoList.children[7].nodes[1].text!,
    );
  }
}
