import 'package:flutter/material.dart';

void toast(BuildContext _context, String text) {
  final scaffold = Scaffold.of(_context);
  Future.delayed(Duration(milliseconds: 500), () {
      scaffold.hideCurrentSnackBar();
  });
  scaffold.showSnackBar(
    SnackBar(content: Text(text)),
  );
}
