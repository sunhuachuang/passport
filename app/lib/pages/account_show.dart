import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/options.dart';
import '../models/did.dart';
import '../global.dart';
import '../widgets/toast.dart';
import '../widgets/header.dart';

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

    final iconColor = Theme.of(context).colorScheme.primary;

    return Container(
      child: ApplyTextOptions(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              child: Column(
                children:<Widget>[
                  header(context, "User Info"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0, // gap between adjacent chips
                    runSpacing: 40.0, // gap between lines
                    children: <Widget>[
                      Container(
                        width: 400,
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                child: user.showAvatar(),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: QrImage(
                                  data: "${user.id},0x${Global.NODE_ADDR}",
                                  version: QrVersions.auto,
                                  size: 200.0,
                                ),
                              ),
                            ]
                          ),
                        ),
                      ),
                      Container(
                        width: 700,
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Center(child: Text('DID & Address')),
                              ListTile(
                                leading: Icon(Icons.person, color: iconColor),
                                title: Text(user.id),
                                onTap: () => {
                                  Clipboard.setData(ClipboardData(text: user.id)),
                                  toast(context, "Copy did ok!"),
                                }
                              ),
                              ListTile(
                                leading: Icon(Icons.location_on, color: iconColor),
                                title: Text('0x' + Global.NODE_ADDR),
                                onTap: () => {
                                  Clipboard.setData(
                                    ClipboardData(text: "0x${Global.NODE_ADDR}")),
                                  toast(context, "Copy addr ok!"),
                                }
                              ),
                            ]
                          )
                        )
                      ),
                    ],
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}
