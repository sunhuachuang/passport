import 'dart:isolate';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

import 'package:assassin/models/did.dart';
import 'package:assassin/models/app.dart';
import 'package:assassin/widgets/relative_time.dart';
import 'package:assassin/providers/running_app.dart';

import 'models/friend.dart';
import 'models/message.dart';
import 'constants.dart';

class ActiveUser extends ChangeNotifier {
  final User owner;
  bool online;
  Map<String, Friend> friends;
  Map<String, TmpFriend> requests;

  SendPort sender; // send message to outside.
  ReceivePort my_receiver;  // receive message from outside.

  Friend activedFriend;
  List<Message> activedMessages;

  List<Message> get recentChats =>
  this.activedMessages != null ? this.activedMessages.reversed.toList() : [];

  ActiveUser({this.owner, this.sender}) {
    this.online = true;
    this.friends = loadFriends(owner.id);
    this.requests = loadRequests(owner.id);
    this.my_receiver = ReceivePort();
    this.sender.send(Bus.sender(AppName.yu, this.owner.id, my_receiver.sendPort));

    this.my_receiver.listen((msg) {
        switch (msg.type) {
          case BusType.sender: return this.sender = msg.params[0];
          case BusType.initialize:
          return this.sender.send(Bus.initialize(AppName.yu, initializeCallback()));
          case BusType.data: {
            msg.params[0].forEach((m, p) {
                _recvCallback(m, p);
            });
          }
        }
    });
  }

  _recvCallback(String method, List params) {
    final remote_id = params[1];

    if (method == 'request-friend') {
      final tmp = buildRequestFromParams(params);
      this.requests[remote_id] = tmp;
    } else  if (method == 'reject-friend') {
      if (this.requests[remote_id] != null) {
        this.requests[remote_id].overIt(false);
      }
    } else if (method == 'agree-friend') {
      if (this.requests[remote_id] != null) {
        this.requests[remote_id].overIt(true);
        final f = buildFriendFromParams(params);
        this.friends[f.id] = f;
      }
    } else if (method == 'message') {
      final msg = params[2];
      final message = Message.decompress(remote_id, msg);

      if (this.activedFriend != null && this.activedFriend.id == remote_id) {
        this.activedMessages.add(message);
      } else {
        // TODO add has new message for friend.
      }
    }

    notifyListeners();
  }

  sendMessage(int type, String content) {
    final message = Message(
      sender: this.owner.id,
      type: type,
      content: content,
      time: new RelativeTime(),
      hasRead: true);

    this.activedMessages.add(message);
    notifyListeners();

    saveMessage(this.owner.id, this.activedFriend.id, message);

    // send to bus
    Map<String, List<String>> data = new Map();
    data['message'] = [this.owner.id, this.activedFriend.id, this.activedFriend.addr,
      message.compress()];
    this.sender.send(Bus.data(AppName.yu, data));
  }

  updateActivedFriend(Friend friend) {
    this.activedFriend = friend;
    this.activedMessages = loadMessages(this.owner.id, friend.id);

    notifyListeners();
  }

  /// request to make a friend.
  requestFriend(String id, String addr, String remark) {
    final tmp = TmpFriend(addr, '', remark, null, true);
    this.requests[id] = tmp;
    notifyListeners();

    // save the request.
    addRequest(this.owner.id, id, tmp);

    // send to bus.
    Map<String, List<String>> data = new Map();
    data['request-friend'] = [ this.owner.id, id, addr, remark];
    this.sender.send(Bus.data(AppName.yu, data));
  }

  /// response the make friend.
  responseFriend(String key, bool isOk) {
    var tmp = this.requests[key];
    tmp.overIt(isOk);
    if (isOk) {
      final f = tmp.toFriend(key);
      this.friends[key] = f;

      // save the friends.
      addFriend(this.owner.id, f);
    }

    notifyListeners();

    // save the request.
    saveRequest(this.owner.id, key, tmp);

    // send to bus.
    Map<String, List<String>> data = new Map();
    data['response-friend'] = [this.owner.id, key, tmp.addr, isOk ? '1' : '0'];
    this.sender.send(Bus.data(AppName.yu, data));
  }

  /// ignore the request.
  ignoreRequest(String key) {
    delRequest(this.owner.id, key);
    this.requests.remove(key);
    notifyListeners();
  }
}
