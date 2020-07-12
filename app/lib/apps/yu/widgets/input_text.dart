import 'package:flutter/material.dart';

import '../common/styles.dart';

class InputText extends StatelessWidget {
  final IconData icon;
  final String text;
  final TextEditingController controller;
  final Function action;

  const InputText({Key key, this.icon, this.text, this.action, this.controller})
  : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: background,
          boxShadow: softShadowsInvert,
          borderRadius: BorderRadius.circular(30.0)),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                boxShadow: softShadows,
                color: background,
                shape: BoxShape.circle),
              child: Icon(
                icon,
                size: 16.0,
                color: Theme.of(context).primaryColor,
            )),
            SizedBox(width: 12.0),
            Expanded(
              child: TextField(
                style: TextStyle(color: textColor, fontSize: 16.0),
                controller: controller,
                decoration: InputDecoration(
                  hintText: text,
                  hintStyle:
                  TextStyle(color: textColor.withOpacity(0.6)),
                  filled: false,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.0, vertical: 12.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
