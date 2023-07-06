import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_view.dart';
import '../account/loan.dart';
import '../app_state.dart';
import '../constants.dart';

/// Displays detailed information about a Loan.
class LoanDetailsView extends AbstractView {
  const LoanDetailsView(this.title, {super.key});

  final String title;

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
    final notFoundLoan = Loan(
      'L',
      'The loan "$title" can no longer be found.',
      DateTime.now(),
      DateTime.now(),
    );
    final appState = context.read<AppState>();
    final loans = appState.session?.loans;
    final loan = loans?.firstWhere(
          (loan) => loan.title == title,
          orElse: () => notFoundLoan,
        ) ??
        notFoundLoan;

    return Center(
      child: Text(loan.title),
    );
  }
}
