import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../account/account.dart';
import '../account/information.dart';
import '../app_state.dart';
import '../constants.dart';
import '../settings/settings_controller.dart';

abstract class AbstractView extends StatelessWidget {
  static const Color lateColor = Color(0xFFFF0000);

  const AbstractView({super.key});

  Drawer? buildDrawer(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name != ConstantsRoutes.root) {
      return null;
    }

    final AppState appState = context.watch<AppState>();
    final SettingsController settingsController =
        context.watch<SettingsController>();
    final Account? account = settingsController.currentAccount;
    final ThemeData themeData = Theme.of(context);
    final TextStyle entryStyle = themeData.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );
    const double iconSize = 40.0;
    final information = appState.session?.information ?? Information.empty();

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
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/logo-edm.png',
                  ),
                ),
              ),
            ),
            arrowColor: const Color(
              0xff000000,
            ),
            onDetailsPressed: () {
              appState.setAccountsExpanded(!appState.expandAccounts);
            },
            otherAccountsPictures: [
              ...settingsController.accounts.asMap().entries.map((entry) {
                return Tooltip(
                  message: entry.value.displayName,
                  child: IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                    ),
                    iconSize: iconSize,
                    color: entry.value.color,
                    onPressed: () {
                      settingsController.updateCurrentAccountIndex(entry.key);
                      appState
                          .setCurrentAccount(settingsController.currentAccount);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
          Visibility(
            visible: appState.expandAccounts,
            child: Column(
              children: [
                ...settingsController.accounts.asMap().entries.map((entry) {
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
                      settingsController.updateCurrentAccountIndex(entry.key);
                      appState
                          .setCurrentAccount(settingsController.currentAccount);
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
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Visibility(
            visible: !appState.expandAccounts &&
                appState.session?.information != null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(context),
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }
}
