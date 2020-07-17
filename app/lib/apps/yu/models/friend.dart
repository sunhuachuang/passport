import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:convert/convert.dart';
import 'package:assassin/models/did.dart';
import 'package:assassin/widgets/relative_time.dart';
import 'package:assassin/common/websocket.dart';

import '../widgets/avatar.dart';

class ActiveUser extends ChangeNotifier {
  final User owner;
  bool online;
  List<Friend> friends;
  Map<String, TmpFriend> requests = {};

  ActiveUser({this.owner}) {
    this.online = true;
    this.friends = loadFriends(owner.id);

    // register callback to ws.
    sockets.addListener("yu", "request-friend", _requestFriend);
    sockets.addListener("yu", "reject-friend", _rejectFriend);
    sockets.addListener("yu", "agree-friend", _agreeFriend);
  }

  static List<Friend> loadFriends(String id) {
    return [u1, u2, u3, u4, u5, u6, u7, u8];
  }

  static List<Friend> loadRequests(String id) {
    //return [u1, u2, u3, u4, u5, u6, u7, u8];
  }

  // callback when receive the response for make a friend.
  _rejectFriend(List params) {
    final my_id = params[0];
    final remote_id = params[1];

    this.requests[remote_id].overIt(false);
    notifyListeners();
  }

  // callback when receive the response for make a friend.
  _agreeFriend(List params) {
    final my_id = params[0];
    final remote_id = params[1];
    final remote_addr = params[2];
    final remote_name = params[3];
    final remote_avatar = params[4];

    if (this.requests[remote_id] != null) {
      this.requests[remote_id].overIt(true);
      this.friends.add(Friend(remote_id, remote_name, remote_avatar, remote_addr, true));
      notifyListeners();
    }
  }

  /// callback when receive the request for make a friend.
  _requestFriend(List params) {
    final my_id = params[0];
    final remote_id = params[1];
    final remote_addr = params[2];
    final remote_name = params[3];
    final remote_avatar = params[4];
    final remark = params[5];

    this.requests[remote_id] = TmpFriend(remote_addr, remote_name, remark,
      remote_avatar.length > 1 ? hex.decode(remote_avatar) : null, false);

    notifyListeners();
  }

  /// request to make a friend.
  requestFriend(String id, String addr, String remark) {
    // save the request.
    this.requests[id] = TmpFriend(addr, "", remark, null, true);
    notifyListeners();

    // send to ws.
    sockets.send('yu', 'request-friend', [this.owner.id, id, addr, remark]);
  }

  /// response the make friend.
  responseFriend(String key, bool isOk) {
    var tmp = this.requests[key];
    tmp.overIt(isOk);
    if (isOk) {
      this.friends.add(tmp.toFriend(key));
    }
    notifyListeners();

    // save the request.

    // send to ws.
    sockets.send('yu', 'response-friend',
      [this.owner.id, key, this.requests[key].addr, isOk ? "1" : "0"]
    );
  }

  /// ignore the request.
  ignoreRequest(String key) {
    this.requests.remove(key);
    notifyListeners();

    // save the request.
  }
}

class Friend {
  final String id;
  String name;
  Uint8List avatar;
  String addr;
  bool online;
  String remark = "";
  Message lastMessage;

  // new friend from backend
  Friend(this.id, String name, String avatar, String addr, [bool online=false]) {
    //this.id = id;
    this.name = name;
    if (avatar.length > 1) {
      this.avatar = hex.decode(avatar);
    } else {
      this.avatar = null;
    }
    this.addr = addr;
    this.online = online;
  }

  Avatar showAvatar([double width = 60.0, double height = 60.0]) {
    return Avatar(
      width: width, height: height, name: this.name, avatar: this.avatar, online: this.online
    );
  }

  static String betterPrint(id) {
    var len = id.length;
    if (len > 8) {
      return id.substring(0, 8) + "..." + id.substring(len - 8, len);
    } else {
      return id;
    }
  }
}

class TmpFriend {
  final String addr;
  final String name;
  final String remark;
  final Uint8List avatar;
  final bool isMe;
  RelativeTime time = RelativeTime();
  bool ok = false;
  bool over = false;

  TmpFriend(this.addr, this.name, this.remark, this.avatar, this.isMe, [this.over=false]);

  overIt(bool isOk) {
    this.over = true;
    this.ok = isOk;
  }

  Friend toFriend(id) {
    var friend = Friend(id, this.name, "", this.addr, false);
    friend.avatar = this.avatar;
    return friend;
  }

  Avatar showAvatar([double width = 60.0, double height = 60.0]) {
    return Avatar(width: width, height: height, name: this.name, avatar: this.avatar);
  }
}

class Message {
  final String sender;
  final int type;
  final String content;
  final RelativeTime time;
  final bool hasRead;

  Message({this.sender, this.type, this.content, this.time, this.hasRead = true});
}

Friend u1 = Friend("1", 'Peter lastony', '', 'addr', true);
Friend u2 = Friend("1", 'Aeter lastony', '', 'addr');
Friend u3 = Friend("1", 'Ceter lastony', '', 'addr', true);
Friend u4 = Friend("1", 'deter lastony', '', 'addr', true);
Friend u5 = Friend("1", 'Eeter lastony', '', 'addr', true);
Friend u6 = Friend("1", 'Peter lastony', '', 'addr', true);
Friend u7 = Friend("1", 'Peter lastony', '', 'addr', true);
Friend u8 = Friend("1", 'Peter lastony', '', 'addr');


List<Message> recentChats = [
  Message(
    sender: "u1",
    type: 0,
    content:
    'Duis anim officia non nisi occaecat quis dolore magna duis deserunt proident.',
    time: new RelativeTime(),
    hasRead: false),
  Message(
    sender: "id",
    type: 0,
    content:
    'Esse laboris dolore eiusmod magna ea magna proident occaecat ullamco consectetur dolor officia.',
    time: new RelativeTime()),
  Message(
    sender: "u1",
    type: 0,
    content: 'hi! how are you! Im fine',
    time: new RelativeTime(),
    hasRead: false),
  Message(
    sender: "id",
    type: 0,
    content: 'Pariatur adipisicing ullamco deserunt elit.',
    time: new RelativeTime()),
  Message(
    sender: "u1",
    type: 0,
    content: 'hi! how are you! Im fine',
    time: new RelativeTime(),
    hasRead: false),
  Message(
    sender: "u1",
    type: 0,
    content:
    'Proident fugiat exercitation nostrud magna Lorem cillum laboris pariatur.',
    time: new RelativeTime()),Message(
    sender: "id",
    type: 0,
    content:
    'Esse laboris dolore eiusmod magna ea magna proident occaecat ullamco consectetur dolor officia.',
    time: new RelativeTime()),
  Message(
    sender: "u1",
    type: 0,
    content: 'hi! how are you! Im fine',
    time: new RelativeTime(),
    hasRead: false),
  Message(
    sender: "id",
    type: 0,
    content: 'Pariatur adipisicing ullamco deserunt elit.',
    time: new RelativeTime()),Message(
    sender: "id",
    type: 0,
    content:
    'Esse laboris dolore eiusmod magna ea magna proident occaecat ullamco consectetur dolor officia.',
    time: new RelativeTime()),
  Message(
    sender: "u1",
    type: 0,
    content: 'hi! how are you! Im fine',
    time: new RelativeTime(),
    hasRead: false),
  Message(
    sender: "id",
    type: 0,
    content: 'Pariatur adipisicing ullamco deserunt elit.',
    time: new RelativeTime()),
];
