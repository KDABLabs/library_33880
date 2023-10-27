import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_view.dart';
import 'informative_empty_view.dart';
import '../constants.dart';
import '../settings/settings_controller.dart';

/// Displays a list of Loan.
class LoanListView extends StatelessAbstractView {
  const LoanListView({
    super.key,
  });

  @override
  AppBar? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Loans'),
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

    if (session.loans == null || session.loans!.isEmpty) {
      return InformativeEmptyView('There is no loan in your library');
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
      restorationId: 'loanListView',
      itemCount: settings.session!.loans!.length,
      itemBuilder: (BuildContext context, int index) {
        final loan = settings.session!.loans![index];
        TextStyle? style;

        if (loan.isLate) {
          style = const TextStyle(
            color: AbstractView.lateColor,
            fontWeight: FontWeight.bold,
          );
        }

        return ListTile(
          leading: Image.asset(
            'assets/images/${loan.kind}.png',
          ),
          title: Text(
            loan.formattedTitle,
            style: style,
          ),
          subtitle: Text(
            loan.formattedReturnDate,
            textAlign: TextAlign.right,
          ),
          onTap: () {
            // Navigate to the details page. If the user leaves and returns to
            // the app after it has been killed while running in the
            // background, the navigation stack is restored.
            Navigator.restorablePushNamed(
              context,
              ConstantsRoutes.loanDetails,
              arguments: loan.title,
            );
          },
        );
      },
    );
  }

  @override
  FloatingActionButton? buildFloatingAction(BuildContext context) {
    final settings = context.read<SettingsController>();
    final session = settings.session;

    if (session == null || session.loans == null || session.loans!.isEmpty) {
      return null;
    }

    return FloatingActionButton(
      onPressed: () {
        settings.extendLoans();
      },
      tooltip: 'Extend loans',
      child: const Icon(
        Icons.lock_reset,
        size: 40,
      ),
    );
  }
}
