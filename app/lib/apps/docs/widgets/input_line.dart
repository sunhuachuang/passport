import 'package:flutter/material.dart';

class Line {
  FocusNode focusInput = FocusNode();
  FocusNode focusMenu = FocusNode();
  LayerLink layerMenu = LayerLink();
  Color colorMenu = Colors.transparent;
  TextEditingController controlInput =  TextEditingController();
}

class InputLine extends StatefulWidget {
  OverlayEntry _overlayEntry;
  Line line;
  int id;

  InputLine({Key key, this.line, this.id}): super(key: key);

  @override
  InputLineState createState() => InputLineState();
}

class InputLineState extends State<InputLine> {
  @override
  void initState() {
    widget.line.focusMenu.addListener(() {
        if (widget.line.focusMenu.hasFocus) {
          print("${widget.id} menu foucs");
          setState(() {
              widget.line.colorMenu = Colors.black.withOpacity(0.3);
              widget._overlayEntry =
              createSelectPopupWindow(widget.line.layerMenu, widget.line.focusMenu);
              Overlay.of(context).insert(widget._overlayEntry);
          });
        } else {
          print("${widget.id} menu lost foucs");
          widget._overlayEntry.remove();
          setState(() {
              widget.line.colorMenu = Colors.transparent;
          });
        }
    });
    widget.line.focusInput.addListener(() {
        if (widget.line.focusInput.hasFocus) {
          setState(() {
              print("${widget.id} input foucs");
              widget.line.colorMenu = Colors.black.withOpacity(0.1);
          });
        } else {
          setState(() {
              print("${widget.id} input lost foucs");
              widget.line.colorMenu = Colors.transparent;
          });
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: widget.line.layerMenu,
      child: Container(
        decoration: BoxDecoration(
          //boxShadow: softShadows,
          //color: Colors.red
        ),
        padding: EdgeInsets.zero, //EdgeInsets.symmetric(horizontal: 10.0),
        margin: EdgeInsets.zero,
        //minHeight: 38,
        child: Row(
          children: <Widget>[
            Container(
              height: 30,
              child: FlatButton(
                color: widget.line.colorMenu,
                textColor: Colors.white,
                shape: CircleBorder(),
                child: Icon(Icons.menu, size: 14.0),
                focusNode: widget.line.focusMenu,
                onPressed: () {
                  widget.line.focusMenu.requestFocus();
                }
              )
            ),
            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 18.0),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: widget.line.controlInput,
                focusNode: widget.line.focusInput,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  //contentPadding: EdgeInsets.all(10),  // Added this
                  //filled: true,
                  //fillColor: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}

OverlayEntry createSelectPopupWindow(layerLink, focusNode) {
  OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {
      return Positioned(
        width: 600, // 700 is desktop width
        child: CompositedTransformFollower(
          offset: Offset(0.0, 50),
          link: layerLink,
          child: Material(
            child: Container(
              color: Colors.black.withOpacity(0.01),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Style:'),
                  SizedBox(height: 5),
                  Wrap(
                    //spacing: 1.0, // gap between adjacent chips
                    //runSpacing: 2.0, // gap between lines
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.format_size)),
                      IconButton(icon: Icon(Icons.format_color_text)),
                      IconButton(icon: Icon(Icons.format_bold)),
                      IconButton(icon: Icon(Icons.format_italic)),
                      IconButton(icon: Icon(Icons.format_clear)),
                      IconButton(icon: Icon(Icons.format_quote)),
                      IconButton(icon: Icon(Icons.format_list_bulleted)),
                      IconButton(icon: Icon(Icons.format_list_numbered)),
                      IconButton(icon: Icon(Icons.format_align_left)),
                      IconButton(icon: Icon(Icons.format_align_center)),
                      IconButton(icon: Icon(Icons.format_align_right))
                    ]
                  ),
                  SizedBox(height: 10),
                  Text('Actions:'),
                  Wrap(
                    //spacing: 5.0, // gap between adjacent chips
                    //runSpacing: 8.0, // gap between lines
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.content_copy),
                        onPressed: () { focusNode.unfocus(); }
                      ),
                      IconButton(icon: Icon(Icons.content_cut),
                        onPressed: () { focusNode.unfocus(); }
                      ),
                      IconButton(icon: Icon(Icons.content_paste),
                        onPressed: () { focusNode.unfocus(); }
                      ),
                    ]
                  ),
                ],
            )),
          ),
        ),
      );
  });
  return overlayEntry;
}
