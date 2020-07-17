import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../common/styles.dart';
import '../widgets/online_indicator.dart';

class Avatar extends StatelessWidget {
  final double width;
  final double height;
  final String name;
  final Uint8List avatar;
  final bool online;

  const Avatar(
    {Key key,
      this.width = 60.0,
      this.height = 60.0,
      this.name,
      this.avatar,
      this.online = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: background,
        boxShadow: softShadows,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(4.0),
            child: this.avatar != null
            ? CircleAvatar(
              minRadius: 25,
              backgroundImage: MemoryImage(this.avatar))
            : CircleAvatar(
              minRadius: 25,
              backgroundColor: background,
              child: Text(this.name.length > 0 ? this.name[0].toUpperCase() : "A")),
            decoration: BoxDecoration(shape: BoxShape.circle)
          ),
          online
              ? Positioned(
                  child: OnlineIndicator(
                    width: 0.26 * width,
                    height: 0.26 * height,
                  ),
                  right: 2,
                  bottom: 2,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
