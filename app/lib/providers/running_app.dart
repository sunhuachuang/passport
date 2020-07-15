import 'package:flutter/material.dart';
import 'package:assassin/common/websocket.dart';

import '../models/app.dart';

class RunningApp with ChangeNotifier {
  Map<AppName, Map<String, App>> _runningApps = {};

  List<App> get runningApps {
    List<App> apps = [];
    _runningApps.forEach((_k, v) {
        v.forEach((_k, a) {
            apps.add(a);
        });
    });
    return apps;
  }

  openApp(App app) {
    if (_runningApps[app.app] == null) {
      sockets.send('system', 'start', [app.appname]);
      _runningApps[app.app] = { app.id: app };
    } else {
      _runningApps[app.app][app.id] = app;
    }

    notifyListeners();
  }

  closeApp(App app) {
    if (_runningApps[app.app] != null) {
      _runningApps[app.app].remove(app.id);
      if (_runningApps[app.app].length == 0) {
        sockets.send('system', 'stop', [app.appname]);
      }
    }

    notifyListeners();
  }
}

