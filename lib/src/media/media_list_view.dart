import 'package:flutter/material.dart';
import 'package:library_33880/src/app_state.dart';
import 'package:provider/provider.dart';

import '../abstract_view.dart';
import '../constants.dart';

/// Displays a list of Media list.
class MediaListView extends AbstractView {
  const MediaListView({
    super.key,
  });

  @override
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: const Text('Media'),
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
    final appState = context.watch<AppState>();

    // To work with lists that may contain a large number of items, it’s best
    // to use the ListView.builder constructor.
    //
    // In contrast to the default ListView constructor, which requires
    // building all Widgets up front, the ListView.builder constructor lazily
    // builds Widgets as they’re scrolled into view.
    return ListView.builder(
      // Providing a restorationId allows the ListView to restore the
      // scroll position when a user leaves and returns to the app after it
      // has been killed while running in the background.
      restorationId: 'mediaListView',
      itemCount: appState.session != null ? appState.session?.mediaList.length : 0,
      itemBuilder: (BuildContext context, int index) {
        final media = appState.session?.mediaList[index];

        return ListTile(
          title: Text('${media?.title}'),
          leading: const CircleAvatar(
            // Display the Flutter Logo image asset.
            foregroundImage: AssetImage('assets/images/flutter_logo.png'),
          ),
          onTap: () {
            // Navigate to the details page. If the user leaves and returns to
            // the app after it has been killed while running in the
            // background, the navigation stack is restored.
            Navigator.restorablePushNamed(
              context,
              ConstantsRoutes.mediaDetails,
            );
          }
        );
      },
    );
  }
}