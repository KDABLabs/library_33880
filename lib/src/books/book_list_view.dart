import 'package:flutter/material.dart';

import '../abstract_view.dart';
import '../constants.dart';
import 'book.dart';

/// Displays a list of Books.
class BooksListView extends AbstractView {
  const BooksListView({
    super.key,
    this.items = const [Book(1), Book(2), Book(3)],
  });

  final Books items;

  @override
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: const Text('Books'),
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
      restorationId: 'booksListView',
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];

        return ListTile(
          title: Text('Book ${item.id}'),
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
              ConstantsRoutes.bookDetails,
            );
          }
        );
      },
    );
  }
}
