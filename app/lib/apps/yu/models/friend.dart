import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:assassin/widgets/relative_time.dart';
import 'package:assassin/global.dart';

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

  Friend.fromLoad(this.id, this.name, this.avatar, this.addr, this.online);

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

  static load(String cache_id) {
    final id = Global.CACHE_DB.read(cache_id + "_id");
    if (id == null) {
      return null;
    }

    final name = Global.CACHE_DB.read(cache_id + "_name");
    final avatar = Global.CACHE_DB.read(cache_id + "_avatar");
    final addr = Global.CACHE_DB.read(cache_id + "_addr");

    return Friend.fromLoad(id, name, avatar, addr, false);
  }

  void save(String cache_id) async {
    await Global.CACHE_DB.write(cache_id + "_id", this.id);
    await Global.CACHE_DB.write(cache_id + "_name", this.name);
    await Global.CACHE_DB.write(cache_id + "_avatar", this.avatar);
    await Global.CACHE_DB.write(cache_id + "_addr", this.addr);
  }

  void del(String cache_id) async {
    await Global.CACHE_DB.delete(cache_id + "_id");
    await Global.CACHE_DB.delete(cache_id + "_name");
    await Global.CACHE_DB.delete(cache_id + "_avatar");
    await Global.CACHE_DB.delete(cache_id + "_addr");
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

  static TmpFriend load(String cache_id) {
    final addr = Global.CACHE_DB.read(cache_id + "_addr");
    final name = Global.CACHE_DB.read(cache_id + "_name");
    final remark = Global.CACHE_DB.read(cache_id + "_remark");
    final avatar = Global.CACHE_DB.read(cache_id + "_avatar");
    final isMe = Global.CACHE_DB.read(cache_id + "_isme");
    final isOver = Global.CACHE_DB.read(cache_id + "_isover");
    final isOk = Global.CACHE_DB.read(cache_id + "_isok");
    var tmp = TmpFriend(addr, name, remark, avatar, isMe);
    if (isOver) {
      tmp.overIt(isOk);
    }
    return tmp;
  }

  void save(String cache_id) async {
    await Global.CACHE_DB.write(cache_id + "_addr", this.addr);
    await Global.CACHE_DB.write(cache_id + "_name", this.name);
    await Global.CACHE_DB.write(cache_id + "_remark", this.remark);
    await Global.CACHE_DB.write(cache_id + "_avatar", this.avatar);
    await Global.CACHE_DB.write(cache_id + "_isme", this.isMe);
    await Global.CACHE_DB.write(cache_id + "_isover", this.over);
    await Global.CACHE_DB.write(cache_id + "_isok", this.ok);
  }

  void del(String cache_id) async {
    await Global.CACHE_DB.delete(cache_id + "_addr");
    await Global.CACHE_DB.delete(cache_id + "_name");
    await Global.CACHE_DB.delete(cache_id + "_remark");
    await Global.CACHE_DB.delete(cache_id + "_avatar");
    await Global.CACHE_DB.delete(cache_id + "_isme");
    await Global.CACHE_DB.delete(cache_id + "_isover");
    await Global.CACHE_DB.delete(cache_id + "_isok");
  }
}
