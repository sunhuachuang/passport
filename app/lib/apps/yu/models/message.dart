import 'package:assassin/widgets/relative_time.dart';

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

  String compress() {
    // TODO
    return this.content;
  }
}
