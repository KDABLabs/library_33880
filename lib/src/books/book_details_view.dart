import 'package:flutter/material.dart';

import '../abstract_view.dart';
import '../constants.dart';

/// Displays detailed information about a Book.
class BookDetailsView extends AbstractView {
  const BookDetailsView({super.key});

  @override
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Book Details'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Navigate to the settings page. If the user leaves and returns
            // to the app after it has been killed while running in the
            // background, the navigation stack is restored.
            Navigator.restorablePushNamed(context, ConstantsRoutes.settings);
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return const Center(
      child: Text('More Information Here'),
    );
  }
}
