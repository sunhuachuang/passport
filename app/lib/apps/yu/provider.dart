import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

import 'package:assassin/common/websocket.dart';
import 'package:assassin/models/did.dart';
import 'package:assassin/widgets/relative_time.dart';

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
    // TODO
    return {
      "local": Friend(id, "Local", "", "", true)
    };
  }

  static Map<String, TmpFriend> loadRequests(String id) {
    // TODO
    return {};
  }

  sendMessage(int type, String content) {

    final message = Message(
      sender: this.owner.id,
      type: type,
      content: content,
      time: new RelativeTime(),
      hasRead: true);
    addMessage(message, true);

    sockets.send('yu', 'message',
      [this.owner.id, this.activedFriend.id, this.activedFriend.addr, message.compress()]
    );
  }

  updateActivedFriend(Friend friend) {
    this.activedFriend = friend;
    // TODO load active messages
    this.activedMessages = [];

    notifyListeners();
  }

  addMessage(Message msg, [isActived=false]) {
    if (isActived || msg.sender == this.activedFriend.id) {
      this.activedMessages.add(msg);
      notifyListeners();
    }

    // TODO db
  }

  delMessage() {}

  addFriend() {}
  delFriend() {}

  addRequest() {}
  delRequest() {}

  /// request to make a friend.
  requestFriend(String id, String addr, String remark) {
    // save the request.
    this.requests[id] = TmpFriend(addr, '', remark, null, true);
    notifyListeners();

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

    // send to ws.
    sockets.send('yu', 'response-friend',
      [this.owner.id, key, this.requests[key].addr, isOk ? '1' : '0']
    );
  }

  /// ignore the request.
  ignoreRequest(String key) {
    this.requests.remove(key);
    notifyListeners();

    // save the request.
  }

  // callback when receive the response for make a friend.
  _rejectFriend(List params) {
    final my_id = params[0];
    final remote_id = params[1];

    this.requests[remote_id].overIt(false);
    notifyListeners();
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
  }

  _message(List params) {
    final my_id = params[0];
    final remote_id = params[1];
    final msg = params[2];
    final message = Message.decompress(remote_id, msg);
    addMessage(message);
  }
}
