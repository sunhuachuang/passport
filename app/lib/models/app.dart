import 'package:flutter/material.dart';

import '../l10n/localizations.dart';

import '../apps/yu/app.dart';
import '../apps/docs/app.dart';

enum AppName {
  yu,
  docs,
  reminder,
  health
}

extension AppNameExtension on AppName {
  String to_str() {
    switch (this) {
      case AppName.yu: return 'yu';
      case AppName.docs: return 'docs';
      case AppName.reminder: return 'reminder';
      case AppName.health: return 'health';
    }
  }
}

AppModel yuModel(localizations, name, id) {
  return AppModel(
    title: localizations.yuTitle,
    subtitle: name,
    appId: id,
    asset: const AssetImage('assets/apps/yu.png'),
    assetDark: const AssetImage('assets/apps/yu_dark.png'),
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
    asset: const AssetImage('assets/apps/docs.png'),
    assetDark: const AssetImage('assets/apps/docs_dark.png'),
    assetColor: const Color(0xFFFEDBD0),
    assetDarkColor: const Color(0xFF543B3C),
    textColor: Colors.red[900],
    route: DocsApp.defaultRoute + '/' + id,
  );
}

AppModel reminderModel(localizations, name, id) {
  return AppModel(
    title: localizations.reminderTitle,
    subtitle: name,
    appId: id,
    asset: const AssetImage('assets/apps/reminder.png'),
    assetDark: const AssetImage('assets/apps/reminder_dark.png'),
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
    asset: const AssetImage('assets/apps/health.png'),
    assetDark: const AssetImage('assets/apps/health_dark.png'),
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
  bool hasNew = false;

  App({
      @required this.app,
      @required this.name,
      @required this.id,
  }) :
  assert(app != null),
  assert(name != null),
  assert(id != null);

  activeNotification() {
    this.hasNew = true;
  }

  clearNotification() {
    this.hasNew = false;
  }

  model(localizations) {
    switch (this.app) {
      case AppName.yu: return yuModel(localizations, this.name, this.id);
      case AppName.docs: return docsModel(localizations, this.name, this.id);
      case AppName.reminder: return reminderModel(localizations, this.name, this.id);
      case AppName.health: return healthModel(localizations, this.name, this.id);
    }
  }

  static AppName parseAppName(String s) {
    switch (s) {
      case 'yu': return AppName.yu;
      case 'docs': return AppName.docs;
      case 'reminder': return AppName.reminder;
      case 'health': return AppName.health;
      return null;
    }
  }

  String get appname {
    return this.app.to_str();
  }

  String get route {
    switch (this.app) {
      case AppName.yu: return YuApp.defaultRoute + '/' + id;
      case AppName.docs: return DocsApp.defaultRoute + '/' + id;
      case AppName.reminder: return YuApp.defaultRoute + '/' + id;
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
