import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/options.dart';
import '../models/did.dart';
import '../global.dart';
import '../widgets/toast.dart';

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
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                user.showAvatar(),
                Center(
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
                ListTile(
                  leading: Icon(Icons.person, color: Colors.blueAccent),
                  title: Text("DID: ${user.printId()}", textAlign: TextAlign.center),
                  onTap: () => {
                    Clipboard.setData(ClipboardData(text: user.id)),
                    toast(context, "Copy id ok!"),
                  }
                ),
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.greenAccent),
                  title: Text('Address: ${Global.NODE_ADDR}', textAlign: TextAlign.center),
                  onTap: () => {
                    Clipboard.setData(ClipboardData(text: "0x${Global.NODE_ADDR}")),
                    toast(context, "Copy addr ok!"),
                  }
                ),
              ]
            )
          ),
        ),
      ),
    );
  }
}
