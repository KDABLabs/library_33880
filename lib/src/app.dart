import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'settings/settings_controller.dart';
import 'theme.dart';
import 'views/add_account_view.dart';
import 'views/loan_details_view.dart';
import 'views/loan_list_view.dart';
import 'views/reservation_details_view.dart';
import 'views/reservation_list_view.dart';
import 'views/settings_view.dart';
import 'views/search_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsController>();

    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: settings,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: lightTheme(
            seedColor:
                settings.currentAccount?.color ?? const Color(0xFFFFFFFF),
          ),
          darkTheme: darkTheme(
            seedColor:
                settings.currentAccount?.color ?? const Color(0xFF000000),
          ),
          themeMode: settings.themeMode,

          debugShowCheckedModeBanner: false,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case ConstantsRoutes.register:
                    return const AddAccountView();
                  case ConstantsRoutes.settings:
                    return const SettingsView();
                  case ConstantsRoutes.reservationDetails:
                    return ReservationDetailsView(
                        routeSettings.arguments as String);
                  case ConstantsRoutes.reservations:
                    return const ReservationListView();
                  case ConstantsRoutes.loanDetails:
                    return LoanDetailsView(routeSettings.arguments as String);
                  case ConstantsRoutes.loans:
                    return const LoanListView();
                  case ConstantsRoutes.searchDetails:
                  //return LoanDetailsView(routeSettings.arguments as String);
                  case ConstantsRoutes.search:
                    return const SearchView();
                  default:
                    {
                      final accounts =
                          context.read<SettingsController>().accounts;

                      if (accounts.isEmpty) {
                        return const AddAccountView();
                      }

                      return const LoanListView();
                    }
                }
              },
            );
          },
        );
      },
    );
  }
}
