import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:assassin/l10n/localizations.dart';
import 'package:assassin/widgets/adaptive.dart';
import 'package:assassin/widgets/relative_time.dart';
import 'package:assassin/models/did.dart';

import 'common/styles.dart';
import 'models/friend.dart';
import 'widgets/button_icon.dart';
import 'widgets/input_text.dart';

import 'provider.dart';

class AddFriendPage extends StatelessWidget {
  const AddFriendPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: background,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 12.0, right: 12.0, top: 26.0, bottom: 10.0),
              decoration: BoxDecoration(
                color: background,
                boxShadow: [
                  BoxShadow(
                    color: darkShadow,
                    offset: Offset(3.0, 0.0),
                    blurRadius: 2.0,
                    spreadRadius: 2.0)
              ]),
              child: Row(
                children: [
                  ButtonIcon(
                    icon: Icons.arrow_back,
                    action: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 30.0),
                  Expanded(
                    child: Text(
                      'Find your friends',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AddFriend(),
            ),
          ]
        )
    ));
  }
}

class AddFriend extends StatefulWidget {
  AddFriend({Key key}) : super(key: key);

  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController userIdEditingController = TextEditingController();
  TextEditingController addrEditingController = TextEditingController();
  TextEditingController remarkEditingController = TextEditingController();
  String name = "";

  Future scan() async {
    final result = await BarcodeScanner.scan();
    if (result.type == 'failed') {
      print(result);
    } else {
      var ss = result.rawContent.split(",");
      this.userIdEditingController.text = ss[0];
      this.addrEditingController.text = ss[1];
    }
  }

  Future chooseImage() async {
    print('TODO');
  }

  send() {
    var id = userIdEditingController.text;
    var addr = addrEditingController.text.substring(2); // remove 0x
    var remark = remarkEditingController.text;

    Provider.of<ActiveUser>(context, listen: false)
    .requestFriend(id, addr, remark);
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<ActiveUser>().requests;
    var requests_key = requests.keys.toList();

    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(minWidth: 200, maxWidth: 700),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        ButtonIcon(icon: Icons.camera_alt, size: 40, action: scan),
                        SizedBox(height: 10.0),
                        Text('Scan Qrcode'),
                      ],
                    ),
                    Column(
                      children: [
                        ButtonIcon(icon: Icons.image, size: 40, action: chooseImage),
                        SizedBox(height: 10.0),
                        Text('Scan Image'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              InputText(icon: Icons.person, text: 'ID',
                controller: userIdEditingController),
              SizedBox(height: 10.0),
              InputText(icon: Icons.location_on, text: 'Address',
                controller: addrEditingController),
              SizedBox(height: 10.0),
              InputText(icon: Icons.turned_in, text: 'Remark',
                controller: remarkEditingController),
              SizedBox(height: 20.0),
              Row(
                children:<Widget>[
                  Spacer(),
                  ButtonIcon(icon: Icons.send, size: 30, action: send, text: 'Send'),
                ]
              ),
              SizedBox(height: 20.0),
              ListView.builder(
                itemCount: requests_key.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  String key = requests_key[index];
                  TmpFriend friend = requests[key];
                  return RequestItem(id: key, friend: friend);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestItem extends StatelessWidget {
  final String id;
  final TmpFriend friend;

  const RequestItem({
      Key key,
      this.id,
      this.friend
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.3,
        actions: <Widget>[
          IconSlideAction(
            caption: 'Ignore',
            color: background,
            foregroundColor: Colors.blue[500],
            icon: Icons.delete,
            onTap: () => {
              context.read<ActiveUser>().ignoreRequest(id),
            }
          ),
        ],
        secondaryActions: <Widget>[
          if (!friend.isMe && !friend.over)
          IconSlideAction(
            caption: 'Agree',
            color: background,
            foregroundColor: Colors.green[500],
            icon: Icons.person_add,
            onTap: () => {
              context.read<ActiveUser>().responseFriend(id, true),
            }
          ),
          if (!friend.isMe && !friend.over)
          IconSlideAction(
            caption: 'Reject',
            color: background,
            foregroundColor: Colors.red[500],
            icon: Icons.flash_off,
            onTap: () => {
              context.read<ActiveUser>().responseFriend(id, false),
            }
          ),
        ],
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            boxShadow: softShadows,
            borderRadius: BorderRadius.circular(18),
            color: friend.over ? Colors.grey[200] : background,
          ),
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    child: friend.showAvatar(),
                  ),
                ],
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          friend.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 5.0),
                        if (friend.over)
                        friend.ok ? Icon(
                          Icons.person_add, size: 15, color: Colors.green[500])
                        : Icon(Icons.flash_off, size: 15, color: Colors.red[500])
                      ]
                    ),
                    SizedBox(height: 3.0),
                    Text(
                      "Remark: ${friend.remark}",
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 3.0),
                    Text(
                      "ID: ${Friend.betterPrint(id)}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 3.0),
                    Text(
                      "Address: 0x${Friend.betterPrint(friend.addr)}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 3.0),
                    Text(
                      friend.time.toString(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    )
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          friend.isMe ? Icons.arrow_forward : Icons.arrow_back,
                          color: Color(0xff8C68EC),
                          size: 20,
                        ),
                      ]
                    )
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
