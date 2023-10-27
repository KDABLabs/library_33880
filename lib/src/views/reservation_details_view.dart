import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_view.dart';
import '../account/reservation.dart';
import '../constants.dart';
import '../settings/settings_controller.dart';

/// Displays detailed information about a Reservation.
class ReservationDetailsView extends StatelessAbstractView {
  final String title;

  const ReservationDetailsView(
    this.title, {
    super.key,
  });

  @override
  AppBar? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Reservation Details'),
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
    final notFoundReservation = Reservation(
      DateTime.now(),
      'The reservation "$title" can no longer be found.',
      'N/A',
      '-',
    );
    final settings = context.watch<SettingsController>();
    final reservations = settings.session?.reservations;
    final reservation = reservations?.firstWhere(
          (reservation) => reservation.title == title,
          orElse: () => notFoundReservation,
        ) ??
        notFoundReservation;
    TextStyle style = const TextStyle(
      fontWeight: FontWeight.bold,
    );

    if (reservation.isLate) {
      style = style.copyWith(
        color: AbstractView.lateColor,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/R.png',
              ),
              Text(
                reservation.formattedTitle,
                style: style,
                textAlign: TextAlign.center,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reservation Date:',
                  ),
                  Text(
                    reservation.formattedReservationDate,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Expiration Date:',
                  ),
                  Text(
                    reservation.formattedExpirationDate,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Availability:',
                  ),
                  Text(
                    reservation.formattedAvailability,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Location:',
                  ),
                  Text(
                    reservation.location,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
