import 'package:flutter/material.dart';

import '../common/styles.dart';

class ButtonIcon extends StatelessWidget {
  final IconData icon;
  final double borderRadius;
  final double size;
  final String text;
  final Function action;

  const ButtonIcon({
      Key key,
      this.icon,
      this.action,
      this.borderRadius = 8.0,
      this.size = 18.0,
      this.text = null
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
          padding: EdgeInsets.all(6.0),
          decoration: BoxDecoration(
              boxShadow: softShadows,
              color: background,
              borderRadius: BorderRadius.circular(borderRadius)),
            child: text != null ?
            Row(
              children: [
                SizedBox(width: 10.0),
                Text(text, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor)),
                SizedBox(width: 10.0),
                Icon(
                  icon,
                  size: size,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 10.0),
              ]
            ) :
            Icon(
              icon,
              size: size,
              color: Theme.of(context).primaryColor,
            )
          ),
    );
  }
}
