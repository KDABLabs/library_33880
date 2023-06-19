import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'account/account.dart';
import 'constants.dart';
import 'settings/settings_controller.dart';

abstract class AbstractView extends StatelessWidget {
  const AbstractView({super.key});

  AppBar buildAppBar(BuildContext context);
  Widget buildBody(BuildContext context);
  Drawer? buildDrawer(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name != ConstantsRoutes.root) {
      return null;
    }

    final Account? account = context.read<SettingsController>().currentAccount;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            accountName: Text(account?.displayName ?? ''),
            accountEmail: Text(account?.login ?? ''),
          ),
          ListTile(
            leading: const Icon(
              Icons.home,
            ),
            title: const Text('Books'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.train,
            ),
            title: const Text('Reservations'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.train,
            ),
            title: const Text('Search'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
      drawer: buildDrawer(context),
    );
  }
}
