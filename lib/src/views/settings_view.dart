import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

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
          const Divider(),
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

class _AccountsListViewState extends AbstractWidgetState<AccountsListView> {
  Future<void> changeColorAt(int index, Color color) async {
    final SettingsController settings = context.read<SettingsController>();
    final result = await showColorPickerDialog(context, color);

    if (result != color) {
      settings.setAccountColorAt(index, result);
    }
  }

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

        return Card(
          key: Key('$index'),
          color: account.color.withAlpha(80),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorIndicator(
                  height: 24,
                  width: 24,
                  color: account.color,
                  borderRadius: 12,
                  onSelect: () => changeColorAt(index, account.color),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  iconSize: 28,
                  hoverColor: Colors.transparent,
                  tooltip: 'Remove ${account.displayName}',
                  onPressed: () {
                    settings.removeAccount(index);
                    showMessage('Account removed!');
                  },
                ),
              ],
            ),
            title: Text(
              account.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(
              account.login,
              textAlign: TextAlign.left,
            ),
            onTap: () => changeColorAt(index, account.color),
          ),
        );
      },
    );
  }
}
