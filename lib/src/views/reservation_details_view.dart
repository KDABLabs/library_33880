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
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Loan Details'),
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
      'L',
      'The reservation "$title" can no longer be found.',
    );
    final settings = context.read<SettingsController>();
    final reservations = settings.session?.reservations;
    final loan = reservations?.firstWhere(
          (reservation) => reservation.title == title,
          orElse: () => notFoundReservation,
        ) ??
        notFoundReservation;

    return Center(
      child: Text(loan.title),
    );
  }
}
