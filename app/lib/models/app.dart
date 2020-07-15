import 'package:flutter/material.dart';

import '../l10n/localizations.dart';

import '../apps/yu/app.dart';

enum AppName {
  yu,
  docs,
  reminders,
  health
}

AppModel yuModel(localizations, name, id) {
  return AppModel(
    title: localizations.yuTitle,
    subtitle: name,
    appId: id,
    asset: const AssetImage('assets/studies/starter_card.png'),
    assetDark: const AssetImage('assets/studies/starter_card_dark.png'),
    assetColor: const Color(0xFFFEDBD0),
    assetDarkColor: const Color(0xFF543B3C),
    textColor: Colors.red[900],
    route: YuApp.defaultRoute + '/' + id,
  );
}

AppModel docsModel(localizations, name, id) {
  return AppModel(
    title: localizations.docsTitle,
    subtitle: name,
    appId: id,
    asset: const AssetImage('assets/studies/crane_card.png'),
    assetDark: const AssetImage('assets/studies/crane_card_dark.png'),
    assetColor: const Color(0xFFFEDBD0),
    assetDarkColor: const Color(0xFF543B3C),
    textColor: Colors.red[900],
    route: YuApp.defaultRoute + '/' + id,
  );
}

AppModel remindersModel(localizations, name, id) {
  return AppModel(
    title: localizations.remindersTitle,
    subtitle: name,
    appId: id,
    asset: const AssetImage('assets/studies/fortnightly_card.png'),
    assetDark: const AssetImage('assets/studies/fortnightly_card_dark.png'),
    assetColor: const Color(0xFFFEDBD0),
    assetDarkColor: const Color(0xFF543B3C),
    textColor: Colors.red[900],
    route: YuApp.defaultRoute + '/' + id,
  );
}

AppModel healthModel(localizations, name, id) {
  return AppModel(
    title: localizations.healthTitle,
    subtitle: name,
    appId: id,
    asset: const AssetImage('assets/studies/rally_card.png'),
    assetDark: const AssetImage('assets/studies/rally_card_dark.png'),
    assetColor: const Color(0xFFFEDBD0),
    assetDarkColor: const Color(0xFF543B3C),
    textColor: Colors.red[900],
    route: YuApp.defaultRoute + '/' + id,
  );
}

class App {
  final AppName app;
  final String name;
  final String id;

  const App({
      @required this.app,
      @required this.name,
      @required this.id,
  }) :
  assert(app != null),
  assert(name != null),
  assert(id != null);

  model(localizations) {
    switch (this.app) {
      case AppName.yu: return yuModel(localizations, this.name, this.id);
      case AppName.docs: return docsModel(localizations, this.name, this.id);
      case AppName.reminders: return remindersModel(localizations, this.name, this.id);
      case AppName.health: return healthModel(localizations, this.name, this.id);
    }
  }

  String get appname {
    switch (this.app) {
      case AppName.yu: return 'yu';
      case AppName.docs: return 'docs';
      case AppName.reminders: return 'reminders';
      case AppName.health: return 'health';
    }
  }

  String get route {
    switch (this.app) {
      case AppName.yu: return YuApp.defaultRoute + '/' + id;
      case AppName.docs: return YuApp.defaultRoute + '/' + id;
      case AppName.reminders: return YuApp.defaultRoute + '/' + id;
      case AppName.health: return YuApp.defaultRoute + '/' + id;
    }
  }
}

class AppModel {
  const AppModel({
      @required this.title,
      @required this.asset,
      @required this.assetDark,
      @required this.assetColor,
      @required this.assetDarkColor,
      @required this.textColor,
      @required this.route,
      @required this.subtitle,
      @required this.appId,
  }) :
  assert(title != null),
  assert(subtitle != null),
  assert(appId != null),
  assert(asset != null),
  assert(assetDark != null),
  assert(assetColor != null),
  assert(assetDarkColor != null),
  assert(textColor != null),
  assert(route != null);

  final String title;
  final String subtitle;
  final String appId;
  final AssetImage asset;
  final AssetImage assetDark;
  final Color assetColor;
  final Color assetDarkColor;
  final Color textColor;
  final String route;

  String get describe => '${appId}@apps';
}
