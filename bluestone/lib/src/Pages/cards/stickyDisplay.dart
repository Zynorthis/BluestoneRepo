import 'package:bluestone/src/components/extras.dart';
import 'package:bluestone/src/components/firebaseContent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StickyDisplay extends StatefulWidget {
  const StickyDisplay({UniqueKey key});

  @override
  _StickyDisplayState createState() => new _StickyDisplayState();
}

class _StickyDisplayState extends State<StickyDisplay> {
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _textBodyController = new TextEditingController();
  String textBodyContent = FirestoreContent.stickySnap.data["textBody"];
  String titleContent = FirestoreContent.stickySnap.data["title"];
  bool visibility = FirestoreContent.stickySnap.data["visibilty"];
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    _titleController.text = titleContent;
    _textBodyController.text = textBodyContent;
    return Scaffold(
        appBar: AppBar(
          title: Text("${_titleController.text}"),
          flexibleSpace: Container(
            alignment: Alignment(0.85, 0.6),
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                print("Delete button Tapped.");
                return showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return new AlertDialog(
                        content:
                            new Text("Are you sure you want to delete this?"),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("Yes"),
                            onPressed: () {
                              print(
                                  "Removing ${FirestoreContent.stickySnap.documentID}...");
                              FirestoreContent.stickyDoc = Firestore.instance
                                  .document(
                                      "Cards/Live/UIDs/${CurrentLoggedInUser.user.uid}/CardIDs/${FirestoreContent.stickySnap.documentID}");
                              FirestoreContent.stickyDoc
                                  .delete()
                                  .whenComplete(() {
                                setState(() {});
                              }).catchError((e) => print(e));
                              print("Document Deleted.");
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                          new FlatButton(
                            child: new Text("No"),
                            onPressed: () {
                              print(
                                  "${FirestoreContent.stickySnap.documentID} will not be deleted.");
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
              color: Colors.white,
              tooltip: "Tap to Delete",
              iconSize: 25.0,
            ),
          ),
        ),
        backgroundColor: ThemeSettings.themeData.backgroundColor,
        floatingActionButton: new FloatingActionButton.extended(
            icon: (_isEditing) ? new Icon(Icons.save) : new Icon(Icons.edit),
            onPressed: () {
              enableEditing();
              if (!_isEditing) {
                _saveEditsToDb();
                titleContent = _titleController.text;
                textBodyContent = _textBodyController.text;
              }
            },
            label: (_isEditing) ? Text("Save") : Text("Edit")),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Padding holds container to hold title
              Container(
                height: 20.0,
                margin: const EdgeInsets.all(20.0),
                child: (_isEditing)
                    ? new TextFormField(
                        controller: _titleController,
                        enableInteractiveSelection: true,
                        maxLength: 18,
                      )
                    : new Row(children: <Widget>[
                        Expanded(
                          child: Text(
                            _titleController.text,
                            textScaleFactor: 1.5,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                        ),
                      ]),
              ),
              // Padding holds child for textbox
              Container(
                height: 80.0,
                margin: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                padding: EdgeInsets.only(bottom: 0.0),
                child: (_isEditing)
                    ? new TextField(
                        controller: _textBodyController,
                        enableInteractiveSelection: true,
                        maxLines: 99,
                        decoration: InputDecoration(
                          hintText: "Textbox",
                          border: OutlineInputBorder(),
                        ),
                      )
                    : new Container(
                        child: Text(
                          _textBodyController.text,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18.0),
                        ),
                      ),
              ),
            ],
          ),
        ));
  }

  void enableEditing() {
    setState(() {
      _isEditing = !_isEditing;
      _isEditing ? print("Editing Enabled") : print("Editing Disabled");
    });
  }

  void _saveEditsToDb() async {
    Map<String, String> data = <String, String>{
      "title": _titleController.text,
      "textBody": _textBodyController.text,
    };
    var id = FirestoreContent.stickySnap.documentID;
    FirestoreContent.stickyDoc = Firestore.instance.document(
        "Cards/Live/UIDs/${CurrentLoggedInUser.user.uid}/CardIDs/$id");
    FirestoreContent.stickyDoc.updateData(data).whenComplete(() {
      print("Document Updated.");
      setState(() {});
    }).catchError((e) => print(e));
  }
}
