import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:assassin/global.dart';

enum FileType {
  markdown,
  image,
  video,
  pdf,
  doc,
  sheet,
  slide,
}

class FileInfo {
  FileType type;
  FileTypeAsset typeAsset;

  String id;
  String name;
  String date;
  String size;

  FileInfo({this.type, this.id, this.name, this.date, this.size}) {
    this.typeAsset = FileTypeAsset(this.type);
  }

  FileInfo.newTmp() {
    this.type = FileType.markdown;
    this.typeAsset = FileTypeAsset(this.type);
    final time = new DateTime.now();
    var formatter = new DateFormat('yyyyMMddHmmss');
    formatter.format(time);
    this.date = formatter.format(time);
    this.id = "tmp_" + this.date;
    this.name = "tmp_" + this.date + ".md";
  }

  bool isEditable() {
    switch (this.type) {
      case FileType.markdown:
        return true;
      default:
        return false;
    }
  }

  Future<void> save() {}

  static List<FileInfo> loadFiles() {}

  static String loadEditableContent(String fileId) {
    //return "markdown, here  ssss\n- sss\n- sss";
    return Global.CACHE_DB.read("docs_" + fileId);
  }

  static Future<void> saveEditableContent(String fileId, String content) async {
    await Global.CACHE_DB.write("docs_" + fileId, content);
  }
}

class FileTypeAsset {
  Image icon;
  Color bg;

  FileTypeAsset(FileType ft) {
    switch (ft) {
      case FileType.markdown:
        this.icon = Image.asset('assets/apps/docs/file_markdown.png');
        this.bg = Colors.black.withAlpha(40);
        break;
      case FileType.image:
        this.icon = Image.asset('assets/apps/docs/file_image.png');
        this.bg = Color(0xfffceeeb);
        break;
      case FileType.video:
        this.icon = Image.asset('assets/apps/docs/file_video.png');
        this.bg = Color(0xfffceeeb);
        break;
      case FileType.pdf:
        this.icon = Image.asset('assets/apps/docs/file_pdf.png');
        this.bg = Color(0xfff8bdba);
        break;
      case FileType.doc:
        this.icon = Image.asset('assets/apps/docs/file_word.png');
        this.bg = Color(0xffeaeaea);
        break;
      case FileType.sheet:
        this.icon = Image.asset('assets/apps/docs/file_sheet.png');
        this.bg = Color(0xff4e5af6);
        break;
      case FileType.slide:
        this.icon = Image.asset('assets/apps/docs/file_markdown.png');
        this.bg = Colors.black.withAlpha(40);
    }
  }
}
