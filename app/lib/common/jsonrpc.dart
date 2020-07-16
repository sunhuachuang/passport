import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../global.dart';

Map jsonrpc = {
  'jsonrpc': '2.0',
  'app': '',
  'method': '',
  'params': [],
  'id': 1,
};

class Response {
  final bool isOk;
  final List params;
  final String error;

  const Response({this.isOk, this.params, this.error});
}

Future<Response> post(String app, String method, List params) async {
  jsonrpc['app'] = app;
  jsonrpc['method'] = method;
  jsonrpc['params'] = params;
  print(json.encode(jsonrpc));

  try {
    final response = await http.post('http://192.168.2.148:8001', body: json.encode(jsonrpc));
    Map data = json.decode(response.body);
    print(data);

    if (data['result'] != null) {
      return Response(isOk: true, params: data['result'], error: '');
    } else {
      return Response(isOk: false, params: [], error: data['error']['message']);
    }
  } catch (e) {
    print(e);
    return Response(isOk: false, params: [], error: 'network error');
  }
}
