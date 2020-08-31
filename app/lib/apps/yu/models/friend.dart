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

  static load(String cacheId) {
    final id = Global.CACHE_DB.read(cacheId + "_id");
    if (id == null) {
      return null;
    }

    final name = Global.CACHE_DB.read(cacheId + "_name");
    final avatar = Global.CACHE_DB.read(cacheId + "_avatar");
    final addr = Global.CACHE_DB.read(cacheId + "_addr");

    return Friend.fromLoad(id, name, avatar, addr, false);
  }

  void save(String cacheId) async {
    await Global.CACHE_DB.write(cacheId + "_id", this.id);
    await Global.CACHE_DB.write(cacheId + "_name", this.name);
    await Global.CACHE_DB.write(cacheId + "_avatar", this.avatar);
    await Global.CACHE_DB.write(cacheId + "_addr", this.addr);
  }

  static del(String cacheId) async {
    await Global.CACHE_DB.delete(cacheId + "_id");
    await Global.CACHE_DB.delete(cacheId + "_name");
    await Global.CACHE_DB.delete(cacheId + "_avatar");
    await Global.CACHE_DB.delete(cacheId + "_addr");
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

  static TmpFriend load(String cacheId) {
    final addr = Global.CACHE_DB.read(cacheId + "_addr");
    final name = Global.CACHE_DB.read(cacheId + "_name");
    final remark = Global.CACHE_DB.read(cacheId + "_remark");
    final avatar = Global.CACHE_DB.read(cacheId + "_avatar");
    final isMe = Global.CACHE_DB.read(cacheId + "_isme");
    final isOver = Global.CACHE_DB.read(cacheId + "_isover");
    final isOk = Global.CACHE_DB.read(cacheId + "_isok");
    var tmp = TmpFriend(addr, name, remark, avatar, isMe);
    if (isOver) {
      tmp.overIt(isOk);
    }
    return tmp;
  }

  Future<void> save(String cacheId) async {
    await Global.CACHE_DB.write(cacheId + "_addr", this.addr);
    await Global.CACHE_DB.write(cacheId + "_name", this.name);
    await Global.CACHE_DB.write(cacheId + "_remark", this.remark);
    await Global.CACHE_DB.write(cacheId + "_avatar", this.avatar);
    await Global.CACHE_DB.write(cacheId + "_isme", this.isMe);
    await Global.CACHE_DB.write(cacheId + "_isover", this.over);
    await Global.CACHE_DB.write(cacheId + "_isok", this.ok);
  }

  static Future<void> del(String cacheId) async {
    await Global.CACHE_DB.delete(cacheId + "_addr");
    await Global.CACHE_DB.delete(cacheId + "_name");
    await Global.CACHE_DB.delete(cacheId + "_remark");
    await Global.CACHE_DB.delete(cacheId + "_avatar");
    await Global.CACHE_DB.delete(cacheId + "_isme");
    await Global.CACHE_DB.delete(cacheId + "_isover");
    await Global.CACHE_DB.delete(cacheId + "_isok");
  }
}
