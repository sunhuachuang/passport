import 'package:intl/intl.dart';

class RelativeTime {
  DateTime time;

  RelativeTime() {
    this.time = new DateTime.now();
  }

  RelativeTime.fromString(String datetime) {
    this.time = DateFormat('yyyy-MM-dd H:mm').parse(datetime);
  }

  String rawString() {
    var formatter = new DateFormat('yyyy-MM-dd H:mm:ss');
    return formatter.format(time);
  }

  String toString() {
    var now = new DateTime.now();
    if (now.year != time.year) {
      var formatter = new DateFormat('yyyy-MM-dd');
      return formatter.format(time);
    }

    if (now.day != time.day) {
      var formatter = new DateFormat('MM-dd H:mm');
      return formatter.format(time);
    }

    var formatter = new DateFormat('H:mm');
    return formatter.format(time);
  }

  bool isAfter(RelativeTime other) {
    return time.isAfter(other.time);
  }

  bool isBefore(RelativeTime other) {
    return time.isBefore(other.time);
  }
}
