import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show describeEnum;
import 'package:flutter/material.dart';

import '../l10n/localizations.dart';
import '../themes/material_demo_theme_data.dart';

import '../pages/account_new.dart';
import '../pages/account_show.dart';

import '../apps/yu/app.dart';

import 'options.dart';
import 'did.dart';
import 'app.dart';

enum PrifleCategory {
  apps,
  network,
  accounts,
}

extension ProfileModelExtension on PrifleCategory {
  String get name => describeEnum(this);

  String displayTitle(AsLocalizations localizations) {
    switch (this) {
      case PrifleCategory.apps:
        return localizations.homeProfileApp;
      case PrifleCategory.network:
        return localizations.homeProfileNetwork;
      case PrifleCategory.accounts:
        return localizations.homeProfileAccount;
    }
    return null;
  }
}

List<ProfileModel> allProfiles(AsLocalizations localizations) =>
    profileApps(localizations) +
    profileNetwork(localizations) +
    profileAccounts(localizations);

class ProfileModel {
  const ProfileModel({
    @required this.title,
    @required this.category,
    @required this.route,
    this.subtitle,
    this.icon,
    this.asset,
    this.color,
  })  : assert(title != null),
        assert(category != null),
        assert(route != null),
        assert(icon != null || asset != null);

  final String title;
  final PrifleCategory category;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
  final AssetImage asset;

  String get describe => '${title}@${category.name}';

  AppModel toApp() {
    return AppModel(
      title: "Yu",
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
    );
  }
}

List<ProfileModel> profileApps(AsLocalizations localizations) {
  return [
    ProfileModel(
      title: localizations.yuTitle,
      subtitle: localizations.yuDescription,
      category: PrifleCategory.apps,
      route: YuApp.defaultRoute + '/' + User.list()[0].id,
      icon: Icons.chat,
      color: Colors.purple,
    ),
    ProfileModel(
      title: localizations.docsTitle,
      subtitle: localizations.docsDescription,
      category: PrifleCategory.apps,
      route: '/apps/1',
      icon: Icons.folder_shared,
      color: Colors.blue,
    ),
    ProfileModel(
      title: localizations.remindersTitle,
      subtitle: localizations.remindersDescription,
      category: PrifleCategory.apps,
      route: '/apps/1',
      icon: Icons.access_alarms,
      color: Colors.orange,
    ),
    ProfileModel(
      title: localizations.healthTitle,
      subtitle: localizations.healthDescription,
      category: PrifleCategory.apps,
      route: '/apps/1',
      icon: Icons.local_hospital,
      color: Colors.green
    ),
  ];
}

List<ProfileModel> profileNetwork(AsLocalizations localizations) {
  return [
    ProfileModel(
      title: localizations.deviceInfo,
      category: PrifleCategory.network,
      route: '/apps',
      icon: Icons.phone_android,
    ),
    ProfileModel(
      title: localizations.devicesNetwork,
      category: PrifleCategory.network,
      route: '/apps',
      icon: Icons.devices_other,
    ),
    ProfileModel(
      title: localizations.distributedNetwork,
      category: PrifleCategory.network,
      route: '/apps',
      icon: Icons.device_hub,
    ),
    ProfileModel(
      title: localizations.p2pNetwork,
      category: PrifleCategory.network,
      route: '/apps',
      icon: Icons.network_check,
    ),
  ];
}

List<ProfileModel> profileAccounts(AsLocalizations localizations) {
  final users = User.list();
  List<ProfileModel> accounts = [];
  users.forEach((user) {
      accounts.add(ProfileModel(
          title: user.name,
          category: PrifleCategory.accounts,
          route: AccountShowPage.baseRoute + '/${user.id}',
          subtitle: user.printId(),
          icon: Icons.person,
      ));
  });

  accounts.add(ProfileModel(
      title: 'New Account',
      category: PrifleCategory.accounts,
      route: AccountNewPage.defaultRoute,
      icon: Icons.add,
  ));

  return accounts;
}
