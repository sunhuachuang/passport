import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:assassin/widgets/relative_time.dart';

import '../widgets/avatar.dart';

import 'message.dart';

class Friend {
  final String id;
  String name;
  Uint8List avatar;
  String addr;
  bool online;
  String remark = '';
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
      return id.substring(0, 8) + '...' + id.substring(len - 8, len);
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
    var friend = Friend(id, this.name, '', this.addr, false);
    friend.avatar = this.avatar;
    return friend;
  }

  Avatar showAvatar([double width = 60.0, double height = 60.0]) {
    return Avatar(width: width, height: height, name: this.name, avatar: this.avatar);
  }
}
