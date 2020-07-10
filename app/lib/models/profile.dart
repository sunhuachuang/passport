import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show describeEnum;
import 'package:flutter/material.dart';

import '../l10n/localizations.dart';
import '../themes/material_demo_theme_data.dart';

import '../pages/account_new.dart';
import '../pages/account_show.dart';

import 'options.dart';

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
  })  : assert(title != null),
        assert(category != null),
        assert(route != null),
        assert(icon != null || asset != null);

  final String title;
  final PrifleCategory category;
  final String subtitle;
  final String route;
  final IconData icon;
  final AssetImage asset;

  String get describe => '${title}@${category.name}';
}

List<ProfileModel> profileApps(AsLocalizations localizations) {
  return [
    ProfileModel(
      title: localizations.yuTitle,
      category: PrifleCategory.apps,
      route: '/apps/1',
      icon: Icons.chat,
    ),
    ProfileModel(
      title: localizations.docsTitle,
      category: PrifleCategory.apps,
      route: '/apps/1',
      icon: Icons.folder_shared,
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
  return [
    ProfileModel(
      title: 'Sun',
      category: PrifleCategory.accounts,
      route: AccountShowPage.baseRoute + '/sun',
      subtitle: '0xsssssssssssssssssssss',
      icon: Icons.person,
    ),
    ProfileModel(
      title: 'Huc',
      category: PrifleCategory.accounts,
      route: AccountShowPage.baseRoute + '/hua',
      subtitle: '0xfffffffffffffffffffff',
      icon: Icons.person,
    ),
    ProfileModel(
      title: 'Chuang',
      category: PrifleCategory.accounts,
      route: AccountShowPage.baseRoute + '/sun',
      subtitle: '0xaasdaasadsasdasdasdff',
      icon: Icons.person,
    ),
    ProfileModel(
      title: 'New Account',
      category: PrifleCategory.accounts,
      route: AccountNewPage.defaultRoute,
      icon: Icons.add,
    ),
  ];
}
