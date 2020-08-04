import 'dart:isolate';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

import 'package:assassin/models/did.dart';
import 'package:assassin/models/app.dart';
import 'package:assassin/widgets/relative_time.dart';
import 'package:assassin/providers/running_app.dart';

import 'constants.dart';

class ActiveUser extends ChangeNotifier {
  final User owner;

  SendPort sender; // send message to outside.
  ReceivePort my_receiver;  // receive message from outside.

  ActiveUser({this.owner, this.sender}) {
    this.my_receiver = ReceivePort();
    this.sender.send(Bus.sender(AppName.docs, this.owner.id, my_receiver.sendPort));

    this.my_receiver.listen((msg) {
        switch (msg.type) {
          case BusType.sender: return this.sender = msg.params[0];
          case BusType.initialize:
          return this.sender.send(Bus.initialize(AppName.docs, initializeCallback()));
          case BusType.data: {
            msg.params[0].forEach((m, p) {
                _recvCallback(m, p);
            });
          }
        }
    });
  }

  _recvCallback(String method, List params) {
    // TODO

    notifyListeners();
  }
}
