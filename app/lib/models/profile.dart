import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show describeEnum;
import 'package:flutter/material.dart';

import '../l10n/localizations.dart';
import '../pages/account_new.dart';
import '../pages/account_show.dart';

import '../apps/yu/app.dart';
import '../global.dart';

import 'did.dart';
import 'options.dart';
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
    this.route,
    this.subtitle,
    this.icon,
    this.asset,
    this.color,
    this.app,
    this.dialog,
  })  : assert(title != null),
        assert(category != null),
        assert(icon != null || asset != null);

  final AppName app;
  final String title;
  final PrifleCategory category;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
  final AssetImage asset;
  final Function dialog;

  String get describe => '${title}@${category.name}';

  App toApp(String name, String id) {
    return App(name: name, id: id, app: this.app);
  }
}

List<ProfileModel> profileApps(AsLocalizations localizations) {
  return [
    ProfileModel(
      title: localizations.yuTitle,
      subtitle: localizations.yuDescription,
      category: PrifleCategory.apps,
      icon: Icons.chat,
      color: Colors.purple,
      app: AppName.yu,
    ),
    ProfileModel(
      title: localizations.docsTitle,
      subtitle: localizations.docsDescription,
      category: PrifleCategory.apps,
      icon: Icons.folder_shared,
      color: Colors.blue,
      app: AppName.docs,
    ),
    ProfileModel(
      title: localizations.remindersTitle,
      subtitle: localizations.remindersDescription,
      category: PrifleCategory.apps,
      icon: Icons.access_alarms,
      color: Colors.orange,
      app: AppName.reminders,
    ),
    ProfileModel(
      title: localizations.healthTitle,
      subtitle: localizations.healthDescription,
      category: PrifleCategory.apps,
      icon: Icons.local_hospital,
      color: Colors.green,
      app: AppName.health
    ),
  ];
}

List<ProfileModel> profileNetwork(AsLocalizations localizations) {
  return [
    ProfileModel(
      title: localizations.devicesInfo,
      category: PrifleCategory.network,
      route: '/apps/1',
      icon: Icons.devices_other,
    ),
    ProfileModel(
      title: localizations.p2pNetwork,
      category: PrifleCategory.network,
      route: '/apps/1',
      icon: Icons.device_hub,
    ),
    ProfileModel(
      title: localizations.addBoostrap,
      category: PrifleCategory.network,
      dialog: addBoostrap,
      color: Colors.green[500],
      icon: Icons.network_check,
    ),
    ProfileModel(
      title: localizations.changeNode,
      category: PrifleCategory.network,
      dialog: changeNode,
      color: Colors.red[500],
      icon: Icons.edit,
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
      title: localizations.addAccount,
      category: PrifleCategory.accounts,
      route: AccountNewPage.defaultRoute,
      icon: Icons.add,
  ));

  return accounts;
}

Widget address(c1, c2) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      new Flexible(
        child: new TextField(
          controller: c1,
          decoration: InputDecoration(
            hintText: 'IP',
            contentPadding: EdgeInsets.all(10)
          )
        ),
      ),
      Text(':'),
      new Container(
        width: 70.0,
        child: new TextField(
          controller: c2,
          decoration: InputDecoration(
            hintText: 'PORT',
            contentPadding: EdgeInsets.all(10)
          )
        ),
      ),
    ],
  );
}

addBoostrap(context) {
  final localizations = AsLocalizations.of(context);
  TextEditingController c1 = TextEditingController();
  TextEditingController c2 = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localizations.addBoostrap,
          style: TextStyle(color: Colors.orangeAccent)),
        content: address(c1, c2),
        actions: <Widget>[
          FlatButton(
            child: new Text(localizations.cancel, style: TextStyle(color: Colors.grey[500])),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: new Text('OK', style: TextStyle(color: Colors.green[500])),
            onPressed: () {
              final addr = c1.text + ':' + c2.text;
              // TODO add error
              Global.addBoostrap(addr);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

changeNode(context) {
  final localizations = AsLocalizations.of(context);
  TextEditingController c1 = TextEditingController();
  TextEditingController c2 = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localizations.changeNode,
          style: TextStyle(color: Colors.orangeAccent)),
        content: address(c1, c2),
        actions: <Widget>[
          FlatButton(
            child: new Text(localizations.cancel, style: TextStyle(color: Colors.grey[500])),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: new Text('OK', style: TextStyle(color: Colors.red[500])),
            onPressed: () {
              final addr = c1.text + ':' + c2.text;
              // TODO add error
              Global.changeNode(addr);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
