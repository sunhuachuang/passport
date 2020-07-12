import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:assassin/l10n/localizations.dart';
import 'package:assassin/widgets/adaptive.dart';
import 'package:assassin/models/did.dart';

import 'common/styles.dart';
import 'models/friend.dart';
import 'widgets/avatar.dart';
import 'detail.dart';
import 'add.dart';

class ActiveFriend extends ChangeNotifier {
  Friend friend;
  ActiveFriend([Friend friend]) {
    this.friend = friend;
  }

  update(Friend friend) {
    this.friend = friend;
    notifyListeners();
  }
}

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
          child: ListenableProvider<ActiveFriend>(
            create: (_) => ActiveFriend(),
            child: Builder(builder: (context) {
                return Row(
                  children: [
                    Container(
                      width: 350,
                      child: ListFriends(),
                    ),
                    SizedBox(width: 20.0),
                    Expanded(
                      child: ChatDetail(me: user.owner.id)
                    ),
                ]);
            }),
      )));
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
  Widget buildGroupAvator(Friend f) {
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
        if (isDisplayDesktop(context)) {
          Provider.of<ActiveFriend>(context, listen: false).update(friend);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                sender: friend,
                me: me,
              ),
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
                  avator: user.owner.avator, name: user.owner.name, online: user.online),
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
                InkWell(
                  onTap: () {
                    if (isDisplayDesktop(context)) {
                      // show Model.
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
                      Icons.person_add,
                      size: 16.0,
                      color: Theme.of(context).primaryColor)
                  )
                ),
                SizedBox(width: 10.0),
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
          // groups
          Container(
            height: 100.0,
            child: Center(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: user.friends.length,
                itemBuilder: (BuildContext ctx, int index) =>
                buildGroupAvator(user.friends[index])),
            ),
          ),

          // friends
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: user.friends.length,
              itemBuilder: (BuildContext ctx, int index) =>
              buildFriendChat(user.friends[index], context, user.owner.id),
          ))
        ],
      ),
    );
  }
}

