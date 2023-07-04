import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../abstract_view.dart';
import '../app_state.dart';
import '../constants.dart';

/// Displays detailed information about a Media.
class MediaDetailsView extends AbstractView {
  const MediaDetailsView(this.title, {super.key});

  final String title;

  @override
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Media Details'),
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
    final appState = context.read<AppState>();
    final mediaList = appState.session!.mediaList;
    final media = mediaList.firstWhere((book) => book.title == title);

    return Center(
      child: Text(media.title),
    );
  }
}
