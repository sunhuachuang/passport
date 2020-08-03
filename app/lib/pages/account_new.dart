import 'dart:io';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

import '../widgets/adaptive.dart';
import '../widgets/header.dart';
import '../models/options.dart';
import '../models/did.dart';
import '../common/jsonrpc.dart' as jsonrpc;
import '../global.dart';

import 'account_show.dart';

class AccountNewPage extends StatefulWidget {
  const AccountNewPage({Key key}) : super(key: key);

  static const String defaultRoute = '/accounts/new';

  @override
  _AccountNewPageState createState() => _AccountNewPageState();
}

class _AccountNewPageState extends State<AccountNewPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mnemonicController = TextEditingController();

  File _image;

  Future getImage() async {
    var image = await pickImage();

    setState(() {
        _image = image;
    });
  }

  _newUser(context) async {
    final name = _nameController.text;
    final mnemonic = _mnemonicController.text;
    final avator = _image != null ? hex.encode(await _image.readAsBytes()) : "";

    final res = await jsonrpc.post('did', 'create', [name, avator, mnemonic]);

    if (res.isOk) {
      // save this User
      final user = User(res.params[0], name, avator);
      await user.save();

      // backend send success, it will redirect to accounts show.
      Navigator.pushReplacementNamed(context, AccountShowPage.baseRoute + '/${user.id}');
    } else {
      // TODO tostor error
      print(res.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      child: ApplyTextOptions(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              header(context, "Set User Info"),
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  alignment: Alignment.center,
                  width: 250,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: 115,
                          child: Column(
                            children: <Widget>[
                              FlatButton(
                                onPressed: getImage,
                                child: Center(
                                  child:
                                  _image == null
                                  ? CircleAvatar(
                                    minRadius: 25,
                                    backgroundColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Icon(
                                        Icons.add_a_photo,
                                        color: Colors.lightBlueAccent,
                                        size: 40
                                      ),
                                    ),
                                  ) : CircleAvatar(
                                    minRadius: 25,
                                    backgroundImage: FileImage(_image),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Icon(
                                        Icons.add_a_photo,
                                        color: Colors.lightBlueAccent.withAlpha(100),
                                        size: 40
                                      ),
                                    ),
                                  )
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'Avatar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.lightBlueAccent,
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              inputText(context, _nameController, 'Name'),
              inputText(context, _mnemonicController, 'Mnemonic'),
              okEnter(context, _newUser, "OK", isDesktop),
            ],
          ),
        ),
      ),
    );
  }
}

Widget inputText(context, _controller, name, [bool isHide=false]) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
    child: Container(
      constraints: BoxConstraints(maxWidth: 400),
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: TextField(
        obscureText: isHide,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlueAccent),
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          fillColor: Colors.lightBlueAccent,
          hintText: name,
          hintStyle: TextStyle(
            color: Colors.lightBlueAccent,
          ),
        ),
        controller: _controller,
      ),
    ),
  );
}

Widget okEnter(context, next, [text="OK", isCenter=false]) {
  return Padding(
    padding: isCenter
    ? const EdgeInsets.only(top: 40, right: 70, left: 70)
    : const EdgeInsets.only(top: 40, right: 50, left: 200),
    child: Container(
      constraints: BoxConstraints(maxWidth: 400),
      alignment: Alignment.bottomRight,
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.blue[300],
            blurRadius: 10.0, // has the effect of softening the shadow
            spreadRadius: 1.0, // has the effect of extending the shadow
            offset: Offset(
              5.0, // horizontal, move right 10
              5.0, // vertical, move down 10
            ),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: FlatButton(
        onPressed: () {
          next(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.lightBlueAccent,
            ),
          ],
        ),
      ),
    ),
  );
}

