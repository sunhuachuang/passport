import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import 'provider.dart';
import 'models/file.dart';

class Editor2Page extends StatefulWidget {
  FileInfo file;
  String fileContent;
  Editor2Page(this.file, this.fileContent, {Key key}) : super(key: key);

  @override
  Editor2PageState createState() => Editor2PageState();
}

class Editor2PageState extends State<Editor2Page> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode inputFocus = FocusNode();

  bool fullPreview = false;
  bool editPreview = false;
  bool fullEdit = false;

  @override
  void initState() {
    super.initState();
    fullEdit = true;
    _controller.text = widget.fileContent;
    inputFocus.requestFocus();
  }

  saveContent() async {
    await FileInfo.saveEditableContent(widget.file.id, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit, color: fullEdit ? Colors.red : Colors.grey),
            onPressed: () {
              setState(() {
                fullEdit = true;
                editPreview = false;
                fullPreview = false;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.chrome_reader_mode,
                color: editPreview ? Colors.red : Colors.grey),
            onPressed: () {
              setState(() {
                fullEdit = false;
                editPreview = true;
                fullPreview = false;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.visibility,
                color: fullPreview ? Colors.red : Colors.grey),
            onPressed: () {
              setState(() {
                fullEdit = false;
                editPreview = false;
                fullPreview = true;
              });
            },
          )
        ],
      ),
      body: Builder(
        builder: (context) => Container(
            padding: EdgeInsets.all(20),
            alignment: Alignment(1.0, 1.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (editPreview || fullEdit)
                    Container(
                      width: editPreview ? 400 : 800,
                      alignment: Alignment(-1.0, -1.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(30),
                      ),
                      child: TextField(
                        style: TextStyle(fontSize: 18.0),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        controller: _controller,
                        focusNode: inputFocus,
                        onChanged: (text) {
                          setState(() {});
                          //print("First text field: $text");
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.all(10), // Added this
                          //filled: true,
                          //fillColor: Colors.grey[300],
                        ),
                      ),
                    ),
                  if (editPreview)
                    Container(
                        padding: EdgeInsets.all(10),
                        child: Center(child: Icon(Icons.arrow_forward))),
                  if (fullPreview || editPreview)
                    Container(
                        width: editPreview ? 400 : 800,
                        alignment: Alignment(-1.0, -1.0),
                        padding: EdgeInsets.all(10),
                        child: MarkdownBody(data: _controller.text))
                ])),
      ),
    );
  }
}
