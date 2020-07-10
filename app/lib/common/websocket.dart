import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

Map jsonrpc = {
  'jsonrpc': '2.0',
  'app': '',
  'method': '',
  'params': [],
  'id': 1,
};

WebSocketsNotifications sockets = new WebSocketsNotifications();

class WebSocketsNotifications {
  static final WebSocketsNotifications _sockets = new WebSocketsNotifications._internal();

  factory WebSocketsNotifications(){
    return _sockets;
  }

  WebSocketsNotifications._internal();

  ///
  /// The WebSocket 'open' channel
  ///
  IOWebSocketChannel _channel;

  ///
  /// Listeners
  /// Like { 'appname': {'method': fn, 'method2': fn2 }, ...}
  Map<String, Map<String, Function>> _listeners = new Map();

  /// ----------------------------------------------------------
  /// Initialization the WebSockets connection with the server
  /// ----------------------------------------------------------
  Future<bool> init(String addr) async {
    ///
    /// Just in case, close any previous communication
    ///
    reset();

    ///
    /// Open a new WebSocket communication
    ///
    var i = 0;

    while (true) {
      try {
        _channel = IOWebSocketChannel.connect("ws://${addr}");
        _channel.stream.listen(_onReceptionOfMessageFromServer);
        return true;
      } catch(e) {
        print('DEBUG Flutter: got websockt error.........retry');
        if (i > 3) {
          return false;
        }

        i += 1;
        await Future.delayed(Duration(seconds: 1), () => true);
        continue;
      }
    }
  }

  /// ----------------------------------------------------------
  /// Closes the WebSocket communication
  /// ----------------------------------------------------------
  reset() {
    if (_channel != null){
      if (_channel.sink != null){
        _channel.sink.close();
      }
    }
  }

  /// ---------------------------------------------------------
  /// Sends a message to the server
  /// ---------------------------------------------------------
  send(String app, String method, List params) {
    jsonrpc['app'] = app;
    jsonrpc['method'] = method;
    jsonrpc['params'] = params;
    //print(json.encode(jsonrpc));

    if (_channel != null){
      if (_channel.sink != null) {
        _channel.sink.add(json.encode(jsonrpc));
      }
    }
  }

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(String app, String method, Function callback) {
    if (_listeners[app] != null) {
      _listeners[app][method] = callback;
    } else {
      _listeners[app] = { method: callback };
    }
  }
  removeListener(String app, String method) {
    if (_listeners[app] != null) {
      _listeners[app].remove(method);
    }
  }

  /// ----------------------------------------------------------
  /// Callback which is invoked each time that we are receiving
  /// a message from the server
  /// ----------------------------------------------------------
  _onReceptionOfMessageFromServer(message) {
    Map response = json.decode(message);

    if (response['result'] != null
      && response['result'].length != 0
      && response['app'] != null
      && response['method'] != null
    ) {
      print(response);
      String app = response['app'];
      String method = response['method'];
      List params = response['result'];
      print(app);
      print(method);

      if (_listeners[app] != null && _listeners[app][method] != null) {
        _listeners[app][method](params);
      } else {
        print("Debug websocket has no this ${app}:${method}, ${params}");
      }
    } else {
      print('Not need handler response.');
    }
  }
}
