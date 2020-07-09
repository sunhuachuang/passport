import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';

String _dynamicLibraryPath(String name, {String path}) {
  if (path == null) path = "";

  // TODO DEBUG
  if (Platform.isLinux) return path + "./native/linux_" + name + ".so";
  if (Platform.isMacOS) return path + "./native/mac_" + name + ".dylib";
  if (Platform.isWindows) return path + "./native/windows_" + name + ".dll";
  if (Platform.isAndroid) return path + "android_" + name + ".so";

  throw Exception("Platform not implemented");
}

DynamicLibrary dlopenPlatformSpecific(String name, {String path}) {
  String fullPath = _dynamicLibraryPath(name, path: path);
  return DynamicLibrary.open(fullPath);
}

typedef ffi_start_daemon = Void Function(Pointer<Utf8> db_path);
typedef dart_start_daemon = void Function(Pointer<Utf8> db_path);

Future<bool> startDaemon(path) async {
  ReceivePort receivePort = ReceivePort();
  Isolate myIsolateInstance = await Isolate.spawn(
    daemonProcess, receivePort.sendPort);

  receivePort.listen((send) {
      send.send(path);
  });
  return true;
}

void daemonProcess(SendPort sendPort) {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  receivePort.listen((path) {
      final DynamicLibrary dylib = dlopenPlatformSpecific("libassassin");
      final fn = dylib.lookup<NativeFunction<ffi_start_daemon>>('start')
      .asFunction<dart_start_daemon>();
      fn(Utf8.toUtf8(path));
  });
}
