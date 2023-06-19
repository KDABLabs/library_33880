import 'package:http/http.dart' as http;

import 'account.dart';

class Session {
  Session(this.account, { this.cookies = const { 'cookielawinfo-checkbox-necessary': 'yes', 'cookielawinfo-checkbox-non-necessary': 'no', 'viewed_cookie_policy': 'yes' } });

  final Account account;
  Map<String, String> cookies;

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

  Future<http.Response> logIn() {
    return http.post(loginUri(), headers: { 'Cookies': cookiesAsString() }, body: { 'login': '$account.login', 'passwd': '$account.password' });
  }

  Future<http.Response> logOut() {
    return http.get(loginUri(), headers: { 'Cookies': cookiesAsString() });
  }
}

/*
Login (POST)
  Form, content-type: application/x-www-form-urlencoded
  Fields: login, passwd (, submit)
  Location : https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/index.php/account
  Cookie: cookielawinfo-checkbox-necessary=yes; cookielawinfo-checkbox-non-necessary=yes; viewed_cookie_policy=yes; session=xyz
*/

/* Login response Response
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
    <head>
        <meta http-equiv="Content-type" content="text/html; charset:iso-8859-1" />
        <meta http-equiv="Content-Language" content="fr-fr" />
        <title>Cassioweb Search Engine 2.0</title>
        <base href="https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/">
        <meta name="keywords" content=â€â€ />
        <meta name="description" content=â€â€ />
        <meta name="copyright" content=â€â€ />
        <link type="text/css" href="/cassioweb/assets/css/smoothness/jquery-ui-1.9.1.custom.min.css" rel="stylesheet" media="screen" />
        <link type="text/css" href="/cassioweb/assets/css/icons/font-awesome.min.css" rel="stylesheet" media="all" />
        <link type="text/css" href="/cassioweb/assets/css/cassioweb.css" rel="stylesheet" media="all" />
        <script type="text/javascript" src="https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/assets/js/jquery-1.8.3.min.js"></script>
        <script type="text/javascript" src="https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/assets/js/app.js"></script>
        <script type="text/javascript" src="https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/assets/js/jquery.tools.min.js"></script>
        <script type="text/javascript" src="https://bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/assets/js/jquery-ui-1.9.1.custom.min.js"></script>
        <!-- Add This Widget -->
        <script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-553c91d9455eb7d0" async="async"></script>
    </head>
    <body>
        <!--
            <pre class='xdebug-var-dump' dir='ltr'>
            <small>/var/www/bibliotheques.cdc-portesentredeuxmers.fr/cassioweb/application/views/pages/account.php:4:</small>
            <b>array</b> <i>(size=0)</i>
             <i><font color='#888a85'>empty</font></i>
            </pre><br/>	<br/>
            -->	
        <div id="cw_content">
            <div class="listnav">
                <h1>Votre compte de bibliothèque</h1>
                <a href='account/logout' style='margin-left:10px;float:right;' class='btnav'>Se déconnecter</a>        
                <a class="btnav" style="float: right;" href="search/" >Retour à la recherche</a>
                <p id="spacer"></p>
            </div>
            <!-- * account details -->
            <p>Bonjour <strong>FULL NAME</strong></p>
            <div class="result infocompte">
                <div class="resultheader"><strong>Mes informations</strong> </div>
                <ul class="labellist">
                    <li><label>Carte no</label>00000000SCXYZA&#160;</li>
                    <li><label>Date inscription</label>12 / 10 / 2022&#160;</li>
                    <li><label>Date renouvellement</label>11 / 10 / 2023&#160;</li>
                    <li><label>Adresse</label>XYZ&#160;</li>
                    <li><label>Code postal</label>33880&#160;</li>
                    <li><label>Ville</label>SAINT CAPRAIS DE BORDEAUX&#160;</li>
                    <li><label>Téléphone</label>06.00.00.00.00&#160;</li>
                    <li><label>Email</label>xyz@gmail.com&#160;</li>
                </ul>
            </div>
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
            <!--<p><b>Mes avis</b></p>-->
        </div>
    </body>
</html>
*/
