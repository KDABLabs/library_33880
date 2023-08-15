import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import 'abstract_view.dart';
import '../account/account.dart';
import '../app_state.dart';
import '../constants.dart';
import '../settings/settings_controller.dart';

class AddAccountView extends StatefulAbstractView {
  const AddAccountView({
    super.key,
  });

  @override
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Add Account'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.restorablePushNamed(context, ConstantsRoutes.settings);
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = context.read<AddAccountViewState>();

    return Form(
      key: state.formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter account display name',
              ),
              controller: state.displayNameController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter account identifier',
              ),
              controller: state.loginController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your account identifier';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter account password',
              ),
              controller: state.passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your account password';
                }
                return null;
              },
            ),
            ColorPicker(
              color: state.color,
              enableShadesSelection: false,
              onColorChanged: (Color value) {
                state.color = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  if (state.formKey.currentState!.validate()) {
                    final appState = context.read<AppState>();
                    final settings = context.read<SettingsController>();
                    Accounts accounts = Accounts.from(settings.accounts);

                    accounts.add(Account(
                      state.displayNameController.text,
                      state.loginController.text,
                      state.passwordController.text,
                      state.color,
                    ));

                    settings.updateAccounts(accounts);
                    settings.updateCurrentAccountIndex(accounts.length - 1);
                    appState.setCurrentAccount(settings.currentAccount);

                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('', (Route route) => false);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account added!')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  AddAccountViewState createState() {
    return AddAccountViewState();
  }
}

class AddAccountViewState extends State<AddAccountView> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Color color = Colors.blue;

  @override
  void dispose() {
    displayNameController.dispose();
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      builder: (BuildContext context, Widget? child) {
        return widget.build(context);
      },
    );
  }
}
