import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

Map jsonrpc = {
  "jsonrpc": "2.0",
  "method": "",
  "params": [],
  "id": 1,
};

WebSocketsNotifications sockets = new WebSocketsNotifications();

class WebSocketsNotifications {
  static final WebSocketsNotifications _sockets = new WebSocketsNotifications._internal();

  factory WebSocketsNotifications(){
    return _sockets;
  }

  WebSocketsNotifications._internal();

  ///
  /// The WebSocket "open" channel
  ///
  IOWebSocketChannel _channel;

  ///
  /// Listeners
  /// List of methods to be called when a new message
  /// comes in.
  ///
  Map<String, Function> _listeners = new Map<String, Function>();

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
        print("DEBUG Flutter: got websockt error.........retry");
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
  reset(){
    if (_channel != null){
      if (_channel.sink != null){
        _channel.sink.close();
      }
    }
  }

  /// ---------------------------------------------------------
  /// Sends a message to the server
  /// ---------------------------------------------------------
  send(String method, List params){
    jsonrpc["method"] = method;
    jsonrpc["params"] = params;
    print(json.encode(jsonrpc));

    if (_channel != null){
      if (_channel.sink != null){
        _channel.sink.add(json.encode(jsonrpc));
      }
    }
  }

  /// ---------------------------------------------------------
  /// Adds a callback to be invoked in case of incoming
  /// notification
  /// ---------------------------------------------------------
  addListener(String method, Function callback){
    _listeners[method] = callback;
  }
  removeListener(String method){
    _listeners.remove(method);
  }

  /// ----------------------------------------------------------
  /// Callback which is invoked each time that we are receiving
  /// a message from the server
  /// ----------------------------------------------------------
  _onReceptionOfMessageFromServer(message){
    Map response = json.decode(message);

    if (response["result"] != null
      && response["result"].length != 0
      && response["method"] != null
      && response["result"]["params"] != null
    ) {
      print(response);
      String method = response["method"];
      List params = response["result"]["params"];

      if (_listeners[method] != null) {
        _listeners[method](params);
      } else {
        print("has no this ${method}, ${params}");
      }
    }
  }
}
