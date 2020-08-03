import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:assassin/l10n/localizations.dart';
import 'package:assassin/widgets/adaptive.dart';
import 'package:assassin/models/did.dart';

import 'common/styles.dart';
import 'models/friend.dart';
import 'models/message.dart';
import 'widgets/avatar.dart';
import 'widgets/button_icon.dart';

import 'provider.dart';
import 'friend.dart';
import 'add.dart';

class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final user = context.watch<ActiveUser>();

    if (isDesktop) {
      return Scaffold(
        body: Container(
          color: background,
          child: Row(
            children: [
              Container(
                width: 350,
                child: ListFriends(),
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: ChatDetail()
              ),
          ])
      ));
    } else {
      return Scaffold(
        body: Container(
          color: background,
          child: ListFriends(),
      ));
    }
  }
}

class ListFriends extends StatefulWidget {
  @override
  _ListFriendsState createState() => _ListFriendsState();
}

class _ListFriendsState extends State<ListFriends> {
  Widget buildGroupAvatar(Friend f) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 6.0),
      child: Column(
        children: <Widget>[
          f.showAvatar(),
          SizedBox(
            height: 4.0,
          ),
          Container(
            width: 64.0,
            child: Text(
              f.name.split(' ')[0],
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget buildFriendChat(Friend friend, BuildContext context, String me) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<ActiveUser>().updateActivedFriend(friend);
        if (!isDisplayDesktop(context)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            friend.showAvatar(),
            SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2.0),
                  if (friend.lastMessage != null)
                  Text(friend.lastMessage.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: friend.lastMessage.hasRead
                      ? textColor.withOpacity(.4)
                      : textColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400))
                ],
            )),
            SizedBox(width: 8.0),
            if (friend.lastMessage != null)
            Text(
              friend.lastMessage.time.toString(),
              style: TextStyle(color: textColor.withOpacity(.6), fontSize: 14.0),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ActiveUser>();
    var friends = user.friends;
    var friend_keys = friends.keys.toList();
    var groups = {};
    var groups_keys = groups.keys.toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                // avatar
                SizedBox(width: 10.0),
                Avatar(width: 40.0, height: 40.0,
                  avatar: user.owner.avatar, name: user.owner.name, online: user.online),
                SizedBox(width: 10.0),
                // name
                Text(user.owner.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold)),
                Expanded(
                  child: Container(),
                ),
                GestureDetector(
                  onTap: () => showUserInfo(
                    context, "${user.owner.id},0x${user.owner.addr}",
                    user.owner.printId(), user.owner.name, user.owner.printAddr()),
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      boxShadow: softShadows,
                      color: background,
                      borderRadius: BorderRadius.circular(8.0)),
                    child: Icon(
                      Icons.info,
                      size: 18.0,
                      color: Theme.of(context).primaryColor,
                    )
                  ),
                ),
                SizedBox(width: 15.0),
              ],
            ),
          ),
          // search box
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: background,
                boxShadow: softShadowsInvert,
                borderRadius: BorderRadius.circular(30.0)),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      boxShadow: softShadows,
                      color: background,
                      shape: BoxShape.circle),
                    child: Icon(
                      Icons.search,
                      size: 16.0,
                      color: Theme.of(context).primaryColor,
                  )),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: textColor, fontSize: 16.0),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle:
                        TextStyle(color: textColor.withOpacity(0.6)),
                        filled: false,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 12.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomHeading(title: 'Groups', icon: Icons.group_add),
          // groups
          (groups_keys.length != 0) ?
          Container(
            height: 100.0,
            child: Center(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: groups_keys.length,
                itemBuilder: (BuildContext ctx, int index) =>
                buildGroupAvatar(groups[groups_keys[index]]),
              )
            ),
          ) : SizedBox(height: 20),
          CustomHeading(title: 'Friends', icon: Icons.person_add),
          // friends
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: friend_keys.length,
              itemBuilder: (BuildContext ctx, int index) =>
              buildFriendChat(friends[friend_keys[index]], context, user.owner.id),
          ))
        ],
      ),
    );
  }
}

class CustomHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const CustomHeading({Key key, @required this.title, @required this.icon}) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
            child: Row(
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                InkWell(
                  onTap: () {
                    if (isDisplayDesktop(context)) {
                      // TODO show Model.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddFriendPage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddFriendPage(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      boxShadow: softShadows,
                      color: background,
                      shape: BoxShape.circle),
                    child: Icon(
                      icon,
                      size: 16.0,
                      color: Theme.of(context).primaryColor)
                  )
                ),
                SizedBox(width: 15.0),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 15,
            width: 30,
            height: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 1],
                  colors: [
                    Color(0xFF8C68EC),
                    Color(0xFF3E8DF3),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

showUserInfo(BuildContext context, String qrcode, String id, String name, String addr) {
  final localizations = AsLocalizations.of(context);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localizations.yuAppFriendInfo,
          style: TextStyle(color: Colors.orangeAccent)),
        content: Container(
          width: 300,
          child: Column(
            children: [
              Center(
                child: QrImage(
                  data: qrcode,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Text(localizations.yuAppScanAddFriend)
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.person, color: Colors.blueAccent),
                title: Text(id, textAlign: TextAlign.left),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.greenAccent),
                title: Text(addr, textAlign: TextAlign.left),
              ),
            ]
        )),
        actions: <Widget>[
          FlatButton(
            child: new Text(localizations.cancel, style: TextStyle(color: Colors.grey[500])),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
