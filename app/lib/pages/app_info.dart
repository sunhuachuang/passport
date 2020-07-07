import 'package:flutter/material.dart';

import '../models/gallery_options.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({
      Key key,
      @required this.slug,
  }) : super(key: key);

  static const String baseRoute = '/apps';
  final String slug;

  @override
  _AppInfoPageState createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ApplyTextOptions(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: EdgeInsetsDirectional.only(start: 0),
              child: IconButton(
                key: const ValueKey('Back'),
                icon: const BackButtonIcon(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
            ),
            actions: [],
          ),
          body: Text(''),
        ),
      ),
    );
  }
}
