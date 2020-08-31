import 'package:flutter/material.dart';

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

  bool isEditable() {
    switch (this.type) {
      case FileType.markdown:
        return true;
      default:
        return false;
    }
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
