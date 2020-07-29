import 'package:convert/convert.dart';

import 'package:assassin/global.dart';

import 'models/friend.dart';
import 'models/message.dart';

/// init this app callback functions.
Map<String, Function> initializeCallback() {
  Map<String, Function> fns = {};

  // add friend
  fns['request-friend'] = recvRequestFriend;
  fns['reject-friend'] = recvRejectFriend;
  fns['agree-friend'] = recvAgreeFriend;

  // message
  fns['message'] = recvMessage;

  return fns;
}

// callback when receive the response for make a friend.
void recvRejectFriend(List params) {
  final my_id = params[0];
  final remote_id = params[1];

  final tmp = readRequest(my_id, remote_id);
  if (tmp != null) {
    tmp.overIt(false);
    saveRequest(my_id, remote_id, tmp);
  }
}

Friend buildFriendFromParams(List params) {
  final remote_id = params[1];
  final remote_addr = params[2];
  final remote_name = params[3];
  final remote_avatar = params[4];

  return Friend(remote_id, remote_name, remote_avatar, remote_addr, false);
}

// callback when receive the response for make a friend.
void recvAgreeFriend(List params) {
  final my_id = params[0];
  final remote_id = params[1];

  final tmp = readRequest(my_id, remote_id);
  if (tmp != null) {
    tmp.overIt(true);
    saveRequest(my_id, remote_id, tmp);

    final f = buildFriendFromParams(params);
    addFriend(my_id, f);
  }
}

TmpFriend buildRequestFromParams(List params) {
  final remote_addr = params[2];
  final remote_name = params[3];
  final remote_avatar = params[4];
  final remark = params[5];

  return TmpFriend(remote_addr, remote_name, remark,
    remote_avatar.length > 1 ? hex.decode(remote_avatar) : null, false);
}

/// callback when receive the request for make a friend.
void recvRequestFriend(List params) {
  final my_id = params[0];
  final remote_id = params[1];

  final tmp = buildRequestFromParams(params);
  addRequest(my_id, remote_id, tmp);
}

void recvMessage(List params) {
  final my_id = params[0];
  final remote_id = params[1];
  final msg = params[2];
  final message = Message.decompress(remote_id, msg);

  saveMessage(my_id, remote_id, message);
}

const String REQUEST = "yu_requests";
const String FRIEND = "yu_friends";
const String MESSAGE = "yu_messages";

Map<String, TmpFriend> loadRequests(String mid) {
  final key = "${REQUEST}_${mid}";

  List<String> ids = Global.CACHE_DB.read(key);
  Map<String, TmpFriend> tmp_friends = {};

  if (ids != null) {
    ids.forEach((a) {
        final t = readRequest(mid, a);
        if (t != null) {
          tmp_friends[a] = t;
        }
    });
  }

  return tmp_friends;
}

TmpFriend readRequest(String mid, String oid) {
  final key = "${REQUEST}_${mid}_${oid}";
  return TmpFriend.load(key);
}

void addRequest(String mid, String oid, TmpFriend tmp) async {
  final list_key = "${REQUEST}_${mid}";
  List<String> ids = Global.CACHE_DB.read(list_key);
  if (ids != null) {
    ids.remove(oid);
  } else {
    ids = [];
  }

  ids.add(oid);

  await Global.CACHE_DB.write(list_key, ids);
  await saveRequest(mid, oid, tmp);
}

void saveRequest(String mid, String oid, TmpFriend tmp) async {
  final key = "${REQUEST}_${mid}_${oid}";
  await tmp.save(key);
}

void delRequest(String mid, String oid) async {
  final list_key = "${REQUEST}_${mid}";
  List<String> ids = Global.CACHE_DB.read(list_key);
  if (ids != null) {
    ids.remove(oid);
    await Global.CACHE_DB.write(list_key, ids);
  }

  final key = "${REQUEST}_${mid}_${oid}";
  await TmpFriend.del(key);
}

Map<String, Friend> loadFriends(String mid) {
  final key = "${FRIEND}_${mid}";

  List<String> ids = Global.CACHE_DB.read(key);
  Map<String, Friend> friends = {};

  if (ids != null) {
    ids.forEach((a) {
        final f = readFriend(mid, a);
        if (f != null) {
          friends[a] = f;
        }
    });
  }

  return friends;
}

Friend readFriend(String mid, String oid) {
  final key = "${FRIEND}_${mid}_${oid}";
  return Friend.load(key);
}

void addFriend(String mid, Friend f) async {
  final list_key = "${FRIEND}_${mid}";
  List<String> ids = Global.CACHE_DB.read(list_key);

  if (ids != null) {
    if (!ids.contains(f.id)) {
      ids.add(f.id);
      await Global.CACHE_DB.write(list_key, ids);
    }
  } else {
    ids = [f.id];
    await Global.CACHE_DB.write(list_key, ids);
  }

  await saveFriend(mid, f);
}

void saveFriend(String mid, Friend f) async {
  final key = "${FRIEND}_${mid}_${f.id}";
  await f.save(key);
}

void delFriend(String mid, String oid) async {
  final list_key = "${FRIEND}_${mid}";
  List<String> ids = Global.CACHE_DB.read(list_key);
  if (ids != null) {
    ids.remove(oid);
    await Global.CACHE_DB.write(list_key, ids);
  }

  final key = "${FRIEND}_${mid}_${oid}";
  await Friend.del(key);
}

List<Message> loadMessages(String mid, String oid) {
  final key = "${MESSAGE}_${mid}_${oid}";
  int ms = Global.CACHE_DB.read(key) ?? 0;

  List<Message> messages = [];

  if (ms != 0) {
    var list = new List<int>.generate(ms, (i) => i + 1);
    list.forEach((i) {
        final m = readMessage(mid, oid, i);
        if (m != null) {
          messages.add(m);
        }
    });
  }

  return messages;
}

Message readMessage(String mid, String oid, int n) {
  final key = "${MESSAGE}_${mid}_${oid}_${n}";
  return Message.load(key);
}

void saveMessage(String mid, String oid, Message m) async {
  final key = "${MESSAGE}_${mid}_${oid}";
  int ms = Global.CACHE_DB.read(key) ?? 0;

  final m_key = "${MESSAGE}_${mid}_${oid}_${ms}";
  await m.save(m_key);

  await Global.CACHE_DB.write(key, ms + 1);
}
