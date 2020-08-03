import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

import '../global.dart';

class User {
  String id;
  String name;
  Uint8List avatar;

  User(String id, String name, [String avatar = ""]) {
    this.id = id;
    this.name = name;
    this.updateAvatar(avatar);
  }

  User.load(String id) {
    this.id = id;
    this.name = Global.CACHE_DB.read(id + "_name") ?? "";
    this.avatar = Global.CACHE_DB.read(id + "_avatar");
  }

  void updateAvatar(String avatar) {
    if (avatar.length > 1) {
      this.avatar = hex.decode(avatar);
    } else {
      this.avatar = null;
    }
  }

  get addr => Global.NODE_ADDR;

  static List<User> list() {
    List<String> accounts = Global.CACHE_DB.read("accounts");
    List<User> users = [];
    if (accounts != null) {
      accounts.forEach((a) {
          users.add(User.load(a));
      });
    }
    return users;
  }

  void save() async {
    List<String> accounts = Global.CACHE_DB.read("accounts");
    if (accounts == null) {
      await Global.CACHE_DB.write("accounts", [id]);
    } else {
      if (!accounts.contains(id)) {
        accounts.add(id);
        await Global.CACHE_DB.write("accounts", accounts);
      }
    }

    await Global.CACHE_DB.write(id + "_name", name);
    await Global.CACHE_DB.write(id + "_avatar", avatar);
  }

  String printShortId() {
    var len = this.id.length;
    if (len > 4) {
      return this.id.substring(0, 4) + "...";
    } else {
      return this.id;
    }
  }

  String printId() {
    var len = this.id.length;
    if (len > 8) {
      return this.id.substring(0, 8) + "..." + this.id.substring(len - 8, len);
    } else {
      return this.id;
    }
  }

  String printAddr() {
    final addr = Global.NODE_ADDR;
    final len = addr.length;
    if (len > 8) {
      return "0x" + addr.substring(0, 6) + "..." + addr.substring(len - 8, len);
    } else {
      return "";
    }
  }

  String hexAvatar() {
    if (this.avatar != null) {
      return hex.encode(this.avatar);
    } else {
      return "";
    }
  }

  CircleAvatar showAvatar() {
    return this.avatar != null ? CircleAvatar(
      backgroundImage: MemoryImage(this.avatar),
      minRadius: 25,
    ) : CircleAvatar(
      child: Text(this.name.length > 0 ? this.name[0].toUpperCase() : "A"),
      minRadius: 25,
      backgroundColor: Colors.grey[300],
    );
  }
}
