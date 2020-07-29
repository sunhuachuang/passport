import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'constants.dart';
import 'l10n/localizations.dart';
import 'models/options.dart';
import 'pages/backdrop.dart';
import 'providers/running_app.dart';
import 'themes/theme_data.dart';
import 'global.dart';


// will run this
void main() => Global.init().then((e) => runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RunningApp()),
        // TODO Accounts
        // TODO ThemeMode
        // TODO AsLocalizations
        // TODO Platform
        // TODO CustomTextDirection
        // TODO TextScaleFactor
      ],
      child: AsApp(),
    )
));

class AsApp extends StatelessWidget {
  const AsApp({
    Key key,
    this.initialRoute,
    this.isTestMode = false,
  }) : super(key: key);

  final bool isTestMode;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: AsOptions(
        themeMode: ThemeMode.system,
        textScaleFactor: systemTextScaleFactorOption,
        customTextDirection: CustomTextDirection.localeBased,
        locale: null,
        timeDilation: timeDilation,
        platform: defaultTargetPlatform,
        isTestMode: isTestMode,
      ),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Assassin',
            debugShowCheckedModeBanner: false,
            themeMode: AsOptions.of(context).themeMode,
            theme: AsThemeData.lightThemeData.copyWith(
              platform: AsOptions.of(context).platform,
            ),
            darkTheme: AsThemeData.darkThemeData.copyWith(
              platform: AsOptions.of(context).platform,
            ),
            localizationsDelegates: const [
              ...AsLocalizations.localizationsDelegates,
              LocaleNamesLocalizationsDelegate()
            ],
            initialRoute: initialRoute,
            supportedLocales: AsLocalizations.supportedLocales,
            locale: AsOptions.of(context).locale,
            localeResolutionCallback: (locale, supportedLocales) {
              deviceLocale = locale;
              return locale;
            },
            onGenerateRoute: RouteConfiguration.onGenerateRoute,
          );
        },
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ApplyTextOptions(
      child: Backdrop(),
    );
  }
}
