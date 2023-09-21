import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../account/account.dart';
import '../account/information.dart';
import '../account/session.dart';
import '../constants.dart';
import '../settings/settings_controller.dart';

abstract mixin class AbstractView {
  static const Color lateColor = Color(0xFFFF0000);

  Drawer? buildDrawer(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';

    if (route.endsWith('details') || route.endsWith('settings')) {
      return null;
    }

    final SettingsController settings = context.watch<SettingsController>();
    final Account? account = settings.currentAccount;
    final ThemeData themeData = Theme.of(context);
    final TextStyle entryStyle = themeData.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );
    const double iconSize = 40.0;
    final information = settings.session?.information ?? Information.empty();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/drawer-background.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            accountName: Text(
              account?.displayName ?? '',
              style: entryStyle,
            ),
            accountEmail: Text(
              account?.login ?? '',
              style: entryStyle,
            ),
            currentAccountPicture: AnimatedContainer(
              duration: const Duration(
                milliseconds: 750,
              ),
              // decoration: const BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage(
              //       'assets/images/flutter_logo.png',
              //     ),
              //   ),
              // ),
            ),
            arrowColor: const Color(
              0xff000000,
            ),
            onDetailsPressed: () {
              settings.setAccountExpanded(!settings.accountExpanded);
            },
            otherAccountsPictures: [
              ...settings.accounts.asMap().entries.map((entry) {
                return Tooltip(
                  message: entry.value.displayName,
                  child: IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                    ),
                    iconSize: iconSize,
                    color: entry.value.color,
                    onPressed: () {
                      settings.setCurrentAccountIndex(entry.key);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
          Visibility(
            visible: settings.accountExpanded,
            child: Column(
              children: [
                ...settings.accounts.asMap().entries.map((entry) {
                  return ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      size: iconSize,
                      color: entry.value.color,
                    ),
                    title: Text(
                      entry.value.displayName,
                    ),
                    titleTextStyle: entryStyle,
                    onTap: () {
                      settings.setCurrentAccountIndex(entry.key);
                    },
                  );
                }).toList(),
                ListTile(
                  leading: const Icon(
                    Icons.person_add,
                    size: iconSize,
                  ),
                  title: const Text(
                    'Add Account',
                  ),
                  titleTextStyle: entryStyle,
                  onTap: () => Navigator.restorablePushNamed(
                      context, ConstantsRoutes.register),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.train,
            ),
            title: const Text(
              'Reservations',
            ),
            titleTextStyle: entryStyle,
            onTap: () => Navigator.restorablePushNamed(
                context, ConstantsRoutes.reservations),
          ),
          ListTile(
            leading: const Icon(
              Icons.shelves,
            ),
            title: const Text(
              'Loans',
            ),
            titleTextStyle: entryStyle,
            onTap: () =>
                Navigator.restorablePushNamed(context, ConstantsRoutes.loans),
          ),
          ListTile(
            leading: const Icon(
              Icons.search,
            ),
            title: const Text(
              'Search',
            ),
            titleTextStyle: entryStyle,
            onTap: () => launchUrl(Session.searchUri()),
          ),
          Visibility(
            visible: !settings.accountExpanded &&
                settings.session?.information != null,
            child: Column(
              children: [
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.card_membership,
                  ),
                  title: Text(
                    information.cardNumber,
                  ),
                  titleTextStyle: entryStyle,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.app_registration,
                  ),
                  title: Text(
                    information.formattedRegistrationDate(),
                  ),
                  titleTextStyle: entryStyle,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.date_range,
                  ),
                  title: Text(
                    information.formattedRenewDate(),
                  ),
                  titleTextStyle: entryStyle,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.location_city,
                  ),
                  title: Text(
                    '${information.address}\n${information.zipCode} ${information.city}',
                  ),
                  titleTextStyle: entryStyle,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.phone_android,
                  ),
                  title: Text(
                    information.phoneNumber,
                  ),
                  titleTextStyle: entryStyle,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.mail,
                  ),
                  title: Text(
                    information.email,
                  ),
                  titleTextStyle: entryStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context);

  Widget buildBody(BuildContext context);

  FloatingActionButton? buildFloatingAction(BuildContext context) {
    return null;
  }

  Widget build(BuildContext context) {
    final settings = context.read<SettingsController>();

    return Scaffold(
      drawer: buildDrawer(context),
      appBar: buildAppBar(context),
      body: RefreshIndicator(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: buildBody(context),
        ),
        onRefresh: () async {
          debugPrint('Refreshing...');
          settings.sync();
        },
      ),
      floatingActionButton: buildFloatingAction(context),
    );
  }
}

abstract class StatelessAbstractView extends StatelessWidget with AbstractView {
  const StatelessAbstractView({super.key});
}

abstract class StatefulAbstractView extends StatefulWidget with AbstractView {
  const StatefulAbstractView({super.key});
}
