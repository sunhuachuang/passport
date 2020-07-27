import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

import 'package:assassin/common/websocket.dart';
import 'package:assassin/models/did.dart';
import 'package:assassin/widgets/relative_time.dart';
import 'package:assassin/global.dart';

import 'models/friend.dart';
import 'models/message.dart';

class ActiveUser extends ChangeNotifier {
  final User owner;
  bool online;
  Map<String, Friend> friends;
  Map<String, TmpFriend> requests;

  Friend activedFriend;
  List<Message> activedMessages;

  List<Message> get recentChats =>
  this.activedMessages != null ? this.activedMessages.reversed.toList() : [];

  ActiveUser({this.owner}) {
    this.online = true;
    this.friends = loadFriends(owner.id);
    this.requests = loadRequests(owner.id);

    // register callback to ws.
    sockets.addListener('yu', 'request-friend', _requestFriend);
    sockets.addListener('yu', 'reject-friend', _rejectFriend);
    sockets.addListener('yu', 'agree-friend', _agreeFriend);
    sockets.addListener('yu', 'message', _message);
  }

  static Map<String, Friend> loadFriends(String id) {
    List<String> ids = Global.CACHE_DB.read("yu_friends");
    Map<String, Friend> friends = {};
    //friends['local'] = Friend(id, "Local", "", "", true);

    if (ids != null) {
      ids.forEach((a) {
          final f = Friend.load("yu_friends_" + a);
          if (f != null) {
            friends[a] = f;
          }
      });
    }

    return friends;
  }

  static Map<String, TmpFriend> loadRequests(String id) {
    List<String> ids = Global.CACHE_DB.read("yu_requests");
    Map<String, TmpFriend> tmp_friends = {};

    if (ids != null) {
      ids.forEach((a) {
          final t = TmpFriend.load("yu_requests_" + a);
          if (t != null) {
            tmp_friends[a] = t;
          }
      });
    }

    return tmp_friends;
  }

  sendMessage(int type, String content) {
    final message = Message(
      sender: this.owner.id,
      type: type,
      content: content,
      time: new RelativeTime(),
      hasRead: true);

    this.activedMessages.add(message);
    notifyListeners();

    sockets.send('yu', 'message',
      [this.owner.id, this.activedFriend.id, this.activedFriend.addr, message.compress()]
    );

    addMessage(message, this.activedFriend.id);
  }

  updateActivedFriend(Friend friend) {
    this.activedFriend = friend;
    int ms = Global.CACHE_DB.read('yu_messages_' + friend.id) ?? 0;
    this.activedMessages = [];

    if (ms != 0) {
      var list = new List<int>.generate(ms, (i) => i + 1);
      var msgs = [];
      list.forEach((i) {
          final m = Message.load("yu_messages_${friend.id}_${i}");
          if (m != null) {
            this.activedMessages.add(m);
          }
      });
    }

    notifyListeners();
  }

  recvMessage(Message msg) {
    if (msg.sender == this.activedFriend.id) {
      this.activedMessages.add(msg);
      notifyListeners();
    }
    addMessage(msg, msg.sender);
  }

  void addMessage(Message msg, String friend_id) async {
    int ms = Global.CACHE_DB.read("yu_messages_" + friend_id) ?? 0;
    msg.save("yu_messages_${friend_id}_${ms}");
    await Global.CACHE_DB.write('yu_messages_' + friend_id, ms + 1);
  }

  delMessage() {
    // TODO
  }

  void addFriend(String id) async {
    final keys = this.friends.keys.toList();
    await Global.CACHE_DB.write('yu_friends', keys);
    print('add friends keys');
    await this.friends[id].save('yu_friends_' + id);
  }

  void delFriend(String id) async {
    this.friends[id].del('yu_friends_' + id);
    this.friends.remove(id);

    final keys = this.friends.keys.toList();
    await Global.CACHE_DB.write('yu_friends', keys);
  }

  void addRequest(String id) async {
    final keys = this.requests.keys.toList();
    await Global.CACHE_DB.write('yu_requests', keys);
    await this.requests[id].save('yu_requests_' + id);
  }

  void delRequest(String id) async {
    this.requests[id].del('yu_requests_' + id);
    this.requests.remove(id);

    final keys = this.requests.keys.toList();
    await Global.CACHE_DB.write('yu_requests', keys);
  }

  /// request to make a friend.
  requestFriend(String id, String addr, String remark) {
    this.requests[id] = TmpFriend(addr, '', remark, null, true);
    notifyListeners();

    // save the request.
    addRequest(id);

    // send to ws.
    sockets.send('yu', 'request-friend', [this.owner.id, id, addr, remark]);
  }

  /// response the make friend.
  responseFriend(String key, bool isOk) {
    var tmp = this.requests[key];
    tmp.overIt(isOk);
    if (isOk) {
      this.friends[key] = tmp.toFriend(key);
    }
    notifyListeners();

    // save the request.
    this.requests[key].save('yu_requests_' + key);

    // save the friends.
    addFriend(key);

    // send to ws.
    sockets.send('yu', 'response-friend',
      [this.owner.id, key, this.requests[key].addr, isOk ? '1' : '0']
    );
  }

  /// ignore the request.
  ignoreRequest(String key) {
    delRequest(key);
    notifyListeners();
  }

  // callback when receive the response for make a friend.
  _rejectFriend(List params) {
    final my_id = params[0];
    final remote_id = params[1];

    this.requests[remote_id].overIt(false);
    notifyListeners();

    // save the request.
    this.requests[remote_id].save('yu_requests_' + remote_id);
  }

  // callback when receive the response for make a friend.
  _agreeFriend(List params) {
    final my_id = params[0];
    final remote_id = params[1];
    final remote_addr = params[2];
    final remote_name = params[3];
    final remote_avatar = params[4];

    if (this.requests[remote_id] != null) {
      this.requests[remote_id].overIt(true);
      this.friends[remote_id] = Friend(
        remote_id, remote_name, remote_avatar, remote_addr, true);
      notifyListeners();
    }

    // save the request.
    this.requests[remote_id].save('yu_requests_' + remote_id);

    // save the friends.
    addFriend(remote_id);
  }

  /// callback when receive the request for make a friend.
  _requestFriend(List params) {
    final my_id = params[0];
    final remote_id = params[1];
    final remote_addr = params[2];
    final remote_name = params[3];
    final remote_avatar = params[4];
    final remark = params[5];

    this.requests[remote_id] = TmpFriend(remote_addr, remote_name, remark,
      remote_avatar.length > 1 ? hex.decode(remote_avatar) : null, false);

    notifyListeners();

    // save the request.
    addRequest(remote_id);
  }

  _message(List params) {
    final my_id = params[0];
    final remote_id = params[1];
    final msg = params[2];
    final message = Message.decompress(remote_id, msg);
    recvMessage(message);
  }
}
