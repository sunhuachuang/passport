import 'package:flutter/material.dart';

import 'widgets/input_line.dart';

class EditorPage extends StatefulWidget {
  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  List<Widget> lines = [];

  Widget addLineButton() {
    return Container(
      alignment: Alignment.centerLeft,
      height: 30,
      child: FlatButton(
        color: Colors.transparent,
        textColor: Colors.black.withOpacity(0.5),
        hoverColor: Colors.black.withOpacity(0.1),
        focusColor: Colors.black.withOpacity(0.3),
        shape: CircleBorder(),
        child: Icon(Icons.add, size: 14.0),
        onPressed: () {
          enterKeyNewLine();
        }
      )
    );
  }

  Widget evaluateButton() {
    return Container(
      alignment: Alignment.center,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(icon: Icon(Icons.thumb_up, size: 30.0, color: Colors.green[300]),
            onPressed: () {
              // UP
            }
          ),
          Text('1'),
          SizedBox(width: 10),
          IconButton(icon: Icon(Icons.thumb_down, size: 30.0, color: Colors.grey[300]),
            onPressed: () {
              // UP
            }
          ),
          Text('2'),
          SizedBox(width: 10),
          IconButton(icon: Icon(Icons.favorite, size: 30.0, color: Colors.red[300]),
            onPressed: () {
              // UP
            }
          ),
          Text('3'),
        ]
      )
    );
  }

  Widget comments() {
    return Container(
      constraints: BoxConstraints(minWidth: 200, maxWidth: 600),
      padding: EdgeInsets.all(50),
      child: Column(
        children: [
          ListTile(
            //leading: CircleAvatar(
            //    backgroundImage: NetworkImage(imageUrl),
            //),
            leading: Icon(Icons.person),
            title: Text('Good post.'),
            trailing: Icon(Icons.reply),
          ),
          Padding(
            padding: EdgeInsets.only(left: 40),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Horse: Good post.'),
                  //trailing: Icon(Icons.reply),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Good post. asdfaf adsfea asdfadf'),
                  //trailing: Icon(Icons.reply),
                ),
              ]
            )
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Good post.'),
            trailing: Icon(Icons.reply),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Good post.'),
            trailing: Icon(Icons.reply),
          )
        ]
      )
    );
  }

  enterKeyNewLine() {
    var line = Line();
    line.focusInput.requestFocus();
    this.lines.add(InputLine(line: line, id: this.lines.length));
    setState(() {});
  }

  upKeyLine() {}

  downKeyLine() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editor page")),
      body: Builder(
        builder: (context) => Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              Column(children: this.lines),
              addLineButton(),
              evaluateButton(),
              comments(),
              SizedBox(height: 50),
            ]
          )
        ),
      ),
    );
  }
}
