import 'package:assassin/widgets/relative_time.dart';
import 'package:assassin/global.dart';

class Message {
  final String sender;
  final int type;
  final String content;
  final RelativeTime time;
  final bool hasRead;

  Message({this.sender, this.type, this.content, this.time, this.hasRead});

  static Message decompress(String sender, String s) {
    return Message(
      sender: sender,
      type: 0,
      content: s,
      time: new RelativeTime(),
      hasRead: false
    );
  }

  static load(String cache_id) {
    final String sender = Global.CACHE_DB.read(cache_id + "_sender");
    if (sender == null) {
      return null;
    }

    final type = Global.CACHE_DB.read(cache_id + "_type");
    final content = Global.CACHE_DB.read(cache_id + "_content");
    final String time_str = Global.CACHE_DB.read(cache_id + "_time");
    final time = RelativeTime.fromString(time_str);
    final hasRead = Global.CACHE_DB.read(cache_id + "_hasread");
    return Message(
      sender: sender, type: type, content: content, time: time, hasRead: hasRead
    );
  }

  void save(String cache_id) async {
    await Global.CACHE_DB.write(cache_id + "_sender", this.sender);
    await Global.CACHE_DB.write(cache_id + "_type", this.type);
    await Global.CACHE_DB.write(cache_id + "_content", this.content);
    await Global.CACHE_DB.write(cache_id + "_time", this.time.rawString());
    await Global.CACHE_DB.write(cache_id + "_hasread", this.hasRead);
  }

  void del(String cache_id) async {
    await Global.CACHE_DB.delete(cache_id + "_sender");
    await Global.CACHE_DB.delete(cache_id + "_type");
    await Global.CACHE_DB.delete(cache_id + "_content");
    await Global.CACHE_DB.delete(cache_id + "_time");
    await Global.CACHE_DB.delete(cache_id + "_hasread");
  }

  String compress() {
    // TODO
    return this.content;
  }
}
