import 'package:flutter/material.dart';

Widget header(context, text) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    padding: const EdgeInsets.only(
      left: 12.0, right: 12.0, top: 26.0, bottom: 10.0),
    child: Row(
      children: [
        IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        SizedBox(width: 20.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                style: TextStyle(
                  color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ]
    ),
  );
}
