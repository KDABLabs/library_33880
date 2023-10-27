import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_view.dart';
import 'informative_empty_view.dart';
import '../constants.dart';
import '../settings/settings_controller.dart';

/// Displays a list of Reservation.
class ReservationListView extends StatelessAbstractView {
  const ReservationListView({
    super.key,
  });

  @override
  AppBar? buildAppBar(BuildContext context) {
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
    final settings = context.watch<SettingsController>();
    final session = settings.session;

    if (session == null) {
      return InformativeEmptyView('No valid session yet...');
    }

    if (session.information == null) {
      return InformativeEmptyView('Syncing...', spin: true);
    }

    if (session.reservations == null || session.reservations!.isEmpty) {
      return InformativeEmptyView('There is no reservation in your library');
    }

    // To work with lists that may contain a large number of items, it’s best
    // to use the ListView.builder constructor.
    //
    // In contrast to the default ListView constructor, which requires
    // building all Widgets up front, the ListView.builder constructor lazily
    // builds Widgets as they’re scrolled into view.
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'reservationListView',
        itemCount: settings.session!.reservations!.length,
        itemBuilder: (BuildContext context, int index) {
          final reservation = settings.session!.reservations![index];
          TextStyle? style;

          if (reservation.isLate) {
            style = const TextStyle(
              color: AbstractView.lateColor,
              fontWeight: FontWeight.bold,
            );
          }

          return Card(
            child: ListTile(
              leading: Image.asset(
                'assets/images/R.png',
              ),
              title: Text(
                reservation.formattedTitle,
                style: style,
              ),
              subtitle: Text(
                reservation.formattedReservationDate,
                textAlign: TextAlign.right,
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
            ),
          );
        },
      ),
    );
  }
}
