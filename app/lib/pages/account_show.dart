import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/options.dart';
import '../models/did.dart';
import '../global.dart';

class AccountShowPage extends StatefulWidget {
  const AccountShowPage({
      Key key,
      @required this.slug,
  }) : super(key: key);

  static const String baseRoute = '/accounts';
  final String slug;

  @override
  _AccountShowPageState createState() => _AccountShowPageState(slug: this.slug);
}

class _AccountShowPageState extends State<AccountShowPage> {
  _AccountShowPageState({
      @required this.slug,
  }): this.user = User.load(slug);

  final String slug;
  final User user;

  @override
  Widget build(BuildContext context) {
    if (this.user == null) {
      Navigator.maybePop(context);
    }

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
          body: Row(
            children: <Widget>[
              Container(
                width: 400,
                child: Column(
                  children: <Widget> [
                    user.avator != null ? CircleAvatar(
                      backgroundImage: MemoryImage(user.avator),
                      minRadius: 25,
                    ) : CircleAvatar(
                      child: Text(user.name.length > 0 ? user.name[0].toUpperCase() : "A"),
                      minRadius: 25,
                      backgroundColor: Colors.lightBlueAccent[200],
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 200),
                      child: Center(
                        child: QrImage(
                          data: "${user.id},0x${Global.NODE_ADDR}",
                          version: QrVersions.auto,
                          size: 200.0,
                          //embeddedImage: NetworkImage(me.avator),
                          //embeddedImageStyle: QrEmbeddedImageStyle(
                          //  size: Size(60, 60),
                          //),
                        ),
                      ),
                    )
                  ]
                ),
              ),
              Container(
                //width: 400,
                child: Column(
                  children: <Widget> [
                    Text('Username: ${user.name}', style: TextStyle(fontSize: 24)),
                    Text('DID: ${slug}', style: TextStyle(fontSize: 16)),
                    Text('Node Addr: ${Global.NODE_ADDR}', style: TextStyle(fontSize: 16)),
                  ]
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}
