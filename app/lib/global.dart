import 'dart:io' show Platform, Directory, File;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/options.dart';
import 'common/native.dart';

Future<String> homeDir() async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    return Future.delayed(Duration(seconds: 0), () => '.tdn'); // PROD: home + "/.tdn"
  }

  if (Platform.isAndroid || Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  throw Exception("Platform not implemented");
}

/// Cache DB for store account info.
class CacheDB {
  var _box;

  Future<bool> init(path) async {
    Hive.init(path);
    this._box = await Hive.openBox('assassinCache');

    return true;
  }

  dynamic read(String key) {
    return Hive.box('assassinCache').get(key);
  }

  void write(String key, value) async {
    await _box.put(key, value);
  }
}

class Global {
  //static Option OPTION = AsOption();
  static CacheDB CACHE_DB = CacheDB();

  // default primitives
  static String DEFAULT_NODE_RPC = "127.0.0.1:8080";

  // cache key name
  static String OPTION_CACHE = "option";

  //static ThemeMode get theme => OPTION.theme;
  //static get lang => _option.lang;

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;

    final path = await homeDir();
    print("Doc: ${path}");
    final isOk = await CACHE_DB.init(path);
    final isDaemon = await startDaemon(path);

    var _option = CACHE_DB.read(OPTION_CACHE);
    if (_option != null) {
      try {
        print(_option);
        //OPTION = Option.fromString(_option);
      } catch (e) {
        print(e);
      }
    }
  }

  //static saveOption() => CACHE_DB.write(OPTION_CACHE, OPTION.toString());
}
