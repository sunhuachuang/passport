import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assassin/models/options.dart';
import 'package:assassin/models/did.dart';
import 'package:assassin/l10n/localizations.dart';
import 'package:assassin/themes/theme_data.dart';

import 'provider.dart';
import 'home.dart';

const _primaryColor = Color(0xFF6200EE);

class DocsApp extends StatelessWidget {
  final String id;
  final SendPort sender;
  const DocsApp({@required this.id, @required this.sender});

  static const String defaultRoute = '/docs';

  @override
  Widget build(BuildContext context) {
    final owner = User.load(id);

    return ListenableProvider<ActiveUser>(
      create: (_) => ActiveUser(owner: owner, sender: this.sender),
      child: Builder(builder: (context) {
          return MaterialApp(
            title: AsLocalizations.of(context).yuTitle,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AsLocalizations.localizationsDelegates,
            supportedLocales: AsLocalizations.supportedLocales,
            locale: AsOptions.of(context).locale,
            initialRoute: DocsApp.defaultRoute,
            routes: {
              DocsApp.defaultRoute: (context) => const _Home(),
            },
            // theme: AsThemeData.lightThemeData.copyWith(
            //   colorScheme: const ColorScheme(
            //     primary: _primaryColor,
            //     primaryVariant: Color(0xFF3700B3),
            //     secondary: Color(0xFF03DAC6),
            //     secondaryVariant: Color(0xFF018786),
            //     background: Colors.white,
            //     surface: Colors.white,
            //     onBackground: Colors.black,
            //     error: Color(0xFFB00020),
            //     onError: Colors.white,
            //     onPrimary: Colors.white,
            //     onSecondary: Colors.black,
            //     onSurface: Colors.black,
            //     brightness: Brightness.light,
            //   ),
            //   platform: AsOptions.of(context).platform,
            // ),
          );
        }
      )
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return const ApplyTextOptions(
      child: HomePage(),
    );
  }
}
