import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import 'abstract_view.dart';
import '../account/account.dart';
import '../constants.dart';
import '../settings/settings_controller.dart';

class AddAccountView extends StatefulAbstractView {
  const AddAccountView({
    super.key,
  });

  @override
  State<AddAccountView> createState() {
    return _AddAccountViewState();
  }
}

class _AddAccountViewState extends AbstractViewState<AddAccountView> {
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
  AppBar? buildAppBar(BuildContext context) {
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
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter account display name',
              ),
              controller: displayNameController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter account identifier',
              ),
              controller: loginController,
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
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your account password';
                }
                return null;
              },
            ),
            ColorPicker(
              color: color,
              enableShadesSelection: false,
              onColorChanged: (Color value) {
                color = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final settings = context.read<SettingsController>();

                    settings.addAccount(Account(
                      displayNameController.text,
                      loginController.text,
                      passwordController.text,
                      color,
                    ));

                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('', (Route route) => false);
                    showMessage('Account added!');
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
}
