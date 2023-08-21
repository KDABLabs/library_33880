import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_view.dart';
import '../views/informative_empty_view.dart';
import '../settings/settings_controller.dart';

class SettingsView extends StatelessAbstractView {
  const SettingsView({
    super.key,
  });

  @override
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Settings'),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final SettingsController settings = context.read<SettingsController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Theme: ',
              ),
              DropdownButton<ThemeMode>(
                // Read the selected themeMode from the controller
                value: settings.themeMode,
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: (ThemeMode? theme) =>
                    settings.setThemeMode(theme ?? ThemeMode.system),
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark Theme'),
                  )
                ],
              ),
            ],
          ),
          Text(
            'Accounts',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Expanded(child: AccountsListView()),
        ],
      ),
    );
  }
}

class AccountsListView extends StatefulWidget {
  const AccountsListView({super.key});

  @override
  State<AccountsListView> createState() => _AccountsListViewState();
}

class _AccountsListViewState extends State<AccountsListView> {
  @override
  Widget build(BuildContext context) {
    final SettingsController settings = context.watch<SettingsController>();

    if (settings.accounts.isEmpty) {
      return InformativeEmptyView('There is no accounts yet');
    }

    return ReorderableListView.builder(
      onReorder: (int oldIndex, int newIndex) {
        settings.moveAccount(oldIndex, newIndex);
      },
      itemCount: settings.accounts.length,
      itemBuilder: (BuildContext context, int index) {
        final account = settings.accounts[index];

        return ListTile(
          key: Key('$index'),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: account.color,
                radius: 12,
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                iconSize: 28,
                hoverColor: Colors.transparent,
                tooltip: 'Remove ${account.displayName}',
                onPressed: () {
                  settings.removeAccount(index);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account removed!')),
                  );
                },
              ),
            ],
          ),
          title: Text(
            account.displayName,
          ),
          subtitle: Text(
            account.login,
            textAlign: TextAlign.left,
          ),
        );
      },
    );
  }
}
