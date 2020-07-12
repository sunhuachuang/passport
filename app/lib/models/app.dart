import 'package:flutter/material.dart';

import '../l10n/localizations.dart';

import '../apps/starter/app.dart';
import '../apps/yu/app.dart';

import '../models/did.dart';

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

List<AppModel> actived_apps(AsLocalizations localizations) {
  // TODO load from db
  return apps(localizations);
}

List<AppModel> apps(AsLocalizations localizations) {
  return [
    AppModel(
      title: localizations.yuTitle,
      subtitle: "Sun",
      appId: 'yu-xxxxxx',
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
      route: YuApp.defaultRoute + '/' + User.list()[0].id,
    ),
  ];
}
