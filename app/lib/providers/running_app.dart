import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:assassin/common/websocket.dart';

import '../global.dart';
import '../models/app.dart';

/// message type use between apps & assassin.
enum BusType {
  /// running app's sendPort.
  /// Receive from app Params: [AppName appname, String appid, SendPort sender].
  /// Send to app Params: SendPort sender.
  sender,
  /// this app's function callback. must be static functions.
  /// Receive Params: [AppName appname, Map<String, Function>].
  /// Send Params: null.
  initialize,
  /// message need send to backend core.
  /// Params: [AppName appname, Map<String, List<String>>].
  /// Send Params: Map<String, List<String>>,
  data,
}

class Bus {
  final BusType type;
  final List params;
  Bus({this.type, this.params});
}

class ActivedApp {
  SendPort sender;
  App app;

  ActivedApp({this.sender, this.app});
}

class RunningApp with ChangeNotifier {
  Map<AppName, Map<String, ActivedApp>> _runningApps = {};
  Map<AppName, Map<String, Function>> _appCallbacks = {};
  final receiver = ReceivePort();

  RunningApp() {
    this.receiver.listen((msg) {
        switch (msg.type) {
          case BusType.sender:
          return _bus_sender(msg.params[0], msg.params[1], msg.params[2]);
          case BusType.initialize:
          return _bus_initialize(msg.params[0], msg.params[1]);
          case BusType.data: return _bus_data(msg.params[0], msg.params[1]);
        }
    });

    sockets.updateCallback(busCallback);
  }

  SendPort get sender => this.receiver.sendPort;

  List<App> get runningApps {
    List<App> apps = [];
    _runningApps.forEach((_k, v) {
        v.forEach((_k, a) {
            apps.add(a.app);
        });
    });
    return apps;
  }

  _bus_sender(AppName app, String id, SendPort sender) {
    this._runningApps[app][id].sender = sender;

    if (this._runningApps[app].length == 1) {
      sender.send(Bus(type: BusType.initialize));
    }
  }

  _bus_initialize(AppName app, Map<String, Function> callbacks) {
    this._appCallbacks[app] = callbacks;
  }

  _bus_data(AppName app, Map<String, List<String>> messages) {
    messages.forEach((m, p) {
        sockets.send(app.to_str(), m, p);
    });
  }

  busCallback(String name, String method, List params) {
    final app = App.parseAppName(name);
    if (app != null) {
      if (this._appCallbacks[app] != null && this._appCallbacks[app][method] != null) {
        this._appCallbacks[app][method](params);
        final did = params[0]; // WARNNING: default did as frist params.

        if (this._runningApps[app] != null && this._runningApps[app][did] != null) {
          // TODO no-actived running app add num mark.

          // send msg to app.
          this._runningApps[app][did].sender.send(
            Bus(type: BusType.data, params: [{ method: params }]
          ));
        }
      } else {
        print("DEBUG: ${name} callback has no this method: ${method}, or not started");
      }
    } else {
      print("DEBUG: no app name: ${name}");
    }
  }

  openApp(App app) {
    if (this._runningApps[app.app] == null || this._runningApps[app.app].length == 0) {
      sockets.send('system', 'start', [app.appname]);
      this._runningApps[app.app] = { app.id: ActivedApp(app: app) };
    } else {
      this._runningApps[app.app][app.id] = ActivedApp(app: app);
    }

    notifyListeners();
  }

  closeApp(App app) {
    if (this._runningApps[app.app] != null) {
      this._runningApps[app.app].remove(app.id);
      if (this._runningApps[app.app].length == 0) {
        sockets.send('system', 'stop', [app.appname]);
        this._runningApps.remove(app.app);
        this._appCallbacks.remove(app.app);
      }
    }

    notifyListeners();
  }
}

