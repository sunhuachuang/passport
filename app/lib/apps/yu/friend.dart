import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assassin/widgets/adaptive.dart';
import 'package:assassin/l10n/localizations.dart';

import 'common/styles.dart';
import 'models/friend.dart';
import 'models/message.dart';
import 'widgets/button_icon.dart';

import 'provider.dart';
import 'home.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: background,
        child: ChatDetail(),
    ));
  }
}

class ChatDetail extends StatefulWidget {
  const ChatDetail({Key key}) : super(key: key);

  @override
  _ChatDetailState createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  TextEditingController textController = TextEditingController();
  String me;
  Friend friend;

  int send_msg_type;
  String send_msg_content;

  sendMessage() {
    send_msg_type = 0;
    send_msg_content = textController.text;
    textController.text = '';
  }

  buildChat(Message message, BuildContext context) {
    final bool isCurrentUser = message.sender != this.me;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(),
          isCurrentUser
          ? this.friend.showAvatar(32.0, 32.0)
          : SizedBox(),
          SizedBox(width: 12.0),
          Expanded(
            child: Align(
              alignment: isCurrentUser ? Alignment.topLeft : Alignment.topRight,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 50,
                  maxWidth: MediaQuery.of(context).size.width * 0.6),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.green[100] : background,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: softShadows),
                child: Text(
                  message.content,
                  style: TextStyle(color: textColor),
                ),
              ),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ActiveUser>();
    final recentChats = user.recentChats;

    this.me = user.owner.id;
    this.friend = user.activedFriend;

    final isDesktop = isDisplayDesktop(context);

    return Column(
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
            children:
            this.friend != null ? [
              if (!isDesktop)
              ButtonIcon(
                icon: Icons.arrow_back,
                action: () => Navigator.pop(context),
              ),
              SizedBox(width: 16.0),
              this.friend.showAvatar(40.0, 40.0),
              SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      this.friend.name,
                      style: TextStyle(
                        color: textColor, fontWeight: FontWeight.bold),
                    ),
                    Text(this.friend.online ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: textColor.withOpacity(.54),
                        fontSize: 14.0,
                    ))
                  ],
                ),
              ),
              SizedBox(width: 10.0),
              ButtonIcon(icon: Icons.phone),
              SizedBox(width: 10.0),
              ButtonIcon(icon: Icons.videocam),
              SizedBox(width: 10.0),
              ButtonIcon(icon: Icons.info),
            ] : [],
          ),
        ),
        Expanded(
          child:
          this.friend != null ? ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: recentChats.length,
            reverse: true,
            itemBuilder: (BuildContext context, index) =>
            buildChat(recentChats[index], context))
          : Center(child: Text(AsLocalizations.of(context).yuAppWelcome,
              style: TextStyle(color: textColor.withOpacity(.54), fontSize: 32.0)))
        ),
        if (this.friend != null)
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          decoration: BoxDecoration(color: background, boxShadow: [
              BoxShadow(
                color: lightShadow,
                offset: Offset(0, 0),
                blurRadius: 6.0,
                spreadRadius: 4.0)
          ]),
          child: Row(
            children: [
              ButtonIcon(icon: Icons.image),
              SizedBox(width: 10.0),
              //ButtonIcon(icon: Icons.camera_alt),
              //SizedBox(width: 10.0),
              //ButtonIcon(icon: Icons.mic),
              //SizedBox(width: 10.0),
              ButtonIcon(icon: Icons.tag_faces),
              SizedBox(width: 10.0),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: background,
                    boxShadow: softShadowsInvert,
                    borderRadius: BorderRadius.circular(30.0)),
                  child: TextField(
                    style: TextStyle(color: textColor, fontSize: 16.0),
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Aa',
                      hintStyle:
                      TextStyle(color: textColor.withOpacity(.6)),
                      filled: false,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 6.0, vertical: 8.0)),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              ButtonIcon(
                icon: Icons.send,
                borderRadius: 18,
                action: () => {
                  sendMessage(),
                  context.read<ActiveUser>().sendMessage(send_msg_type, send_msg_content),
                }
              ),
            ],
          ),
        )
      ],
    );
  }
}
