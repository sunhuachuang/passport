import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:convert/convert.dart';
import 'package:assassin/models/did.dart';
import 'package:assassin/widgets/relative_time.dart';

import '../widgets/avatar.dart';

class ActiveUser extends ChangeNotifier {
  final User owner;
  bool online;
  List<Friend> friends;
  Map<String, TmpFriend> requests = {
    "1": TmpFriend("111", "Sun", "", null, true),
    "2": TmpFriend("222", "hua", "i ame", null, false, true),
    "3": TmpFriend("333", "chuang", "like", null, false),
  };

  ActiveUser({this.owner}) {
    this.online = true;
    this.friends = loadFriends(owner.id);
  }

  static List<Friend> loadFriends(String id) {
    return [u1, u2, u3, u4, u5, u6, u7, u8];
  }

  removeRequest(String key) {
    this.requests.remove(key);
  }

  overRequest(String key, bool isOk) {
    this.requests[key].overIt(isOk);
  }
}

class Friend {
  final String id;
  String name;
  Uint8List avator;
  String addr;
  bool online;
  String remark = "";
  Message lastMessage;

  // new friend from backend
  Friend(this.id, String name, String avator, String addr, [bool online=false]) {
    //this.id = id;
    this.name = name;
    if (avator.length > 1) {
      this.avator = hex.decode(avator);
    } else {
      this.avator = null;
    }
    this.addr = addr;
    this.online = online;
  }

  Avatar showAvatar([double width = 60.0, double height = 60.0]) {
    return Avatar(
      width: width, height: height, name: this.name, avator: this.avator, online: this.online
    );
  }
}

class TmpFriend {
  final String addr;
  final String name;
  final String remark;
  final Uint8List avator;
  final bool isMe;
  RelativeTime time = RelativeTime();
  bool ok = false;
  bool over = false;

  TmpFriend(this.addr, this.name, this.remark, this.avator, this.isMe, [this.over=false]);

  overIt(bool isOk) {
    this.over = true;
    this.ok = ok;
  }

  Avatar showAvatar([double width = 60.0, double height = 60.0]) {
    return Avatar(width: width, height: height, name: this.name, avator: this.avator);
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


final List<Message> recentChats = [
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
    time: new RelativeTime()),
];
