import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import '../global.dart';

class User {
  String id;
  String name;
  Uint8List avator;

  User(String id, String name, [String avator = ""]) {
    this.id = id;
    this.name = name;
    this.updateAvator(avator);
  }

  User.load(String id) {
    this.id = id;
    this.name = Global.CACHE_DB.read(id + "_name") ?? "";
    this.avator = Global.CACHE_DB.read(id + "_avator");
  }

  void updateAvator(String avator) {
    if (avator.length > 1) {
      this.avator = hex.decode(avator);
    } else {
      this.avator = null;
    }
  }

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
    await Global.CACHE_DB.write(id + "_avator", avator);
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

  String printAvator() {
    if (this.avator != null) {
      return hex.encode(this.avator);
    } else {
      return "";
    }
  }
}
