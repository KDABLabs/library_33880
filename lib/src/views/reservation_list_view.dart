import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_view.dart';
import '../app_state.dart';
import '../constants.dart';

/// Displays a list of Reservation.
class ReservationListView extends AbstractView {
  const ReservationListView({
    super.key,
  });

  @override
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Reservations'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Navigate to the settings page. If the user leaves and returns
            // to the app after it has been killed while running in the
            // background, the navigation stack is restored.
            Navigator.restorablePushNamed(
              context,
              ConstantsRoutes.settings,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final appState = context.watch<AppState>();
    final session = appState.session;

    if (session == null || session.reservations == null) {
      return const Center(
        child: Text('No valid session yet...'),
      );
    } else if (session.reservations!.isEmpty) {
      return const Center(
        child: Text('There is no reservation in your library'),
      );
    }

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
      restorationId: 'reservationListView',
      itemCount: appState.session!.reservations!.length,
      itemBuilder: (BuildContext context, int index) {
        final reservation = appState.session!.reservations![index];

        return ListTile(
          title: Text(reservation.title),
          leading: Image.asset(
            'assets/images/${reservation.kind}.png',
            width: 38,
            height: 38,
          ),
          onTap: () {
            // Navigate to the details page. If the user leaves and returns to
            // the app after it has been killed while running in the
            // background, the navigation stack is restored.
            Navigator.restorablePushNamed(
              context,
              ConstantsRoutes.reservationDetails,
              arguments: reservation.title,
            );
          },
        );
      },
    );
  }
}
