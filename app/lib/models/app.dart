import 'package:flutter/material.dart';

import '../l10n/gallery_localizations.dart';

import '../apps/starter/app.dart';

class AppModel {
  const AppModel({
    @required this.title,
    @required this.subtitle,
    @required this.appId,
    @required this.asset,
    @required this.assetDark,
    @required this.assetColor,
    @required this.assetDarkColor,
    @required this.textColor,
    @required this.route,
  })  : assert(title != null),
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

List<AppModel> actived_apps(GalleryLocalizations localizations) {
  // TODO load from db
  return apps(localizations);
}

List<AppModel> apps(GalleryLocalizations localizations) {
  return [
    AppModel(
      title: localizations.yuTitle,
      subtitle: localizations.yuDescription,
      appId: 'yu',
      asset: const AssetImage(
        'assets/studies/starter_card.png',
        package: 'flutter_gallery_assets',
      ),
      assetDark: const AssetImage(
        'assets/studies/starter_card_dark.png',
        package: 'flutter_gallery_assets',
      ),
      assetColor: const Color(0xFFFEDBD0),
      assetDarkColor: const Color(0xFF543B3C),
      textColor: Colors.red[900],
      route: StarterApp.defaultRoute,
    ),
    AppModel(
      title: localizations.docsTitle,
      subtitle: localizations.docsDescription,
      appId: 'docs',
      asset: const AssetImage(
        'assets/studies/starter_card.png',
        package: 'flutter_gallery_assets',
      ),
      assetDark: const AssetImage(
        'assets/studies/starter_card_dark.png',
        package: 'flutter_gallery_assets',
      ),
      assetColor: const Color(0xFFFEDBD0),
      assetDarkColor: const Color(0xFF543B3C),
      textColor: Colors.blue[900],
      route: StarterApp.defaultRoute,
    ),
    AppModel(
      title: localizations.healthTitle,
      subtitle: localizations.healthDescription,
      appId: 'health',
      asset: const AssetImage(
        'assets/studies/starter_card.png',
        package: 'flutter_gallery_assets',
      ),
      assetDark: const AssetImage(
        'assets/studies/starter_card_dark.png',
        package: 'flutter_gallery_assets',
      ),
      assetColor: const Color(0xFFFEDBD0),
      assetDarkColor: const Color(0xFF543B3C),
      textColor: Colors.green[900],
      route: StarterApp.defaultRoute,
    ),
    AppModel(
      title: localizations.remindersTitle,
      subtitle: localizations.remindersDescription,
      appId: 'reminders',
      asset: const AssetImage(
        'assets/studies/starter_card.png',
        package: 'flutter_gallery_assets',
      ),
      assetDark: const AssetImage(
        'assets/studies/starter_card_dark.png',
        package: 'flutter_gallery_assets',
      ),
      assetColor: const Color(0xFFFEDBD0),
      assetDarkColor: const Color(0xFF543B3C),
      textColor: Colors.brown[900],
      route: StarterApp.defaultRoute,
    ),
    AppModel(
      title: localizations.starterAppTitle,
      subtitle: localizations.starterAppDescription,
      appId: 'starter',
      asset: const AssetImage(
        'assets/studies/starter_card.png',
        package: 'flutter_gallery_assets',
      ),
      assetDark: const AssetImage(
        'assets/studies/starter_card_dark.png',
        package: 'flutter_gallery_assets',
      ),
      assetColor: const Color(0xFFFEDBD0),
      assetDarkColor: const Color(0xFF543B3C),
      textColor: Colors.brown[900],
      route: StarterApp.defaultRoute,
    ),
  ];
}
