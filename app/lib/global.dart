import 'dart:io' show Platform, Directory, File;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'models/options.dart';
import 'common/native.dart';
import 'common/websocket.dart';

Future<File> pickImage() async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    return Future.delayed(Duration(seconds: 0), () => null);
  }

  if (Platform.isAndroid || Platform.isIOS) {
    return await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 80.0, maxHeight: 80.0);
  }
}

Future<String> homeDir() async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    return Future.delayed(Duration(seconds: 0), () => '.tdn'); // PROD: home + '/.tdn'
  }

  if (Platform.isAndroid || Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  throw Exception('Platform not implemented');
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

  void delete(String key) async {
    await _box.delete(key);
  }
}

initSocket() {
  sockets.init(Global.WS_RPC);
  sockets.addListener('system', 'addr', Global.updateNodeAddr);
  sockets.send('system', 'addr', []);
  sockets.send('system', 'start', ['did']);
}

class Global {
  //static Option OPTION = AsOption();
  static CacheDB CACHE_DB = CacheDB();

  /// default jsonrpc http addr.
  static String HTTP_RPC = '127.0.0.1:8000';

  /// default jsonrpc websocket addr.
  static String WS_RPC = '127.0.0.1:8080';

  // cache key name
  static String OPTION_CACHE = 'option';

  static String NODE_ADDR = '0x';

  //static ThemeMode get theme => OPTION.theme;
  //static get lang => _option.lang;

  static updateNodeAddr(params) {
    Global.NODE_ADDR = params[0];
  }

  static changeNode(http_addr, ws_addr) {
    Global.HTTP_RPC = http_addr;
    Global.WS_RPC = ws_addr;
    initSocket();
  }

  static List<String> splitRpc() {
    final r1 = Global.HTTP_RPC.split(':');
    final r2 = Global.WS_RPC.split(':');
    return [r1[0], r1[1], r2[0], r2[1]];
  }

  static addBoostrap(addr) {
    sockets.send('system', 'boostrap', [addr]);
  }

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();

    final path = await homeDir();
    print("Doc: ${path}");
    final isOk = await CACHE_DB.init(path);
    //final isDaemon = await startDaemon(path); // DEBUG

    initSocket();

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

  static String printAddr() {
    var len = NODE_ADDR.length;
    if (len > 8) {
      return "0x" + NODE_ADDR.substring(0, 6) + "..." + NODE_ADDR.substring(len - 8, len);
    } else {
      return "";
    }
  }
}
