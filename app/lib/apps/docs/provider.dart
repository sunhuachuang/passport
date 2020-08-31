import 'dart:isolate';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

import 'package:assassin/models/did.dart';
import 'package:assassin/models/app.dart';
import 'package:assassin/widgets/relative_time.dart';
import 'package:assassin/providers/running_app.dart';

import 'constants.dart';
import 'models/file.dart';

class ActiveUser extends ChangeNotifier {
  final User owner;

  SendPort sender; // send message to outside.
  ReceivePort myReceiver; // receive message from outside.

  ActiveUser({this.owner, this.sender}) {
    this.myReceiver = ReceivePort();
    this
        .sender
        .send(Bus.sender(AppName.docs, this.owner.id, myReceiver.sendPort));

    this.myReceiver.listen((msg) {
      switch (msg.type) {
        case BusType.sender:
          return this.sender = msg.params[0];
        case BusType.initialize:
          return this
              .sender
              .send(Bus.initialize(AppName.docs, initializeCallback()));
        case BusType.data:
          {
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

  List<FileInfo> recentFiles() {
    return [
      FileInfo(
          id: "0",
          name: "first.md",
          size: "10MB",
          date: "2020/2/20",
          type: FileType.markdown),
    ];
  }

  String getEditFile(String fileId) {
    return "markdown, here  ssss\n- sss\n- sss";
  }

  saveEditFile(String fileId, String filecontent) {
    //
  }
}
