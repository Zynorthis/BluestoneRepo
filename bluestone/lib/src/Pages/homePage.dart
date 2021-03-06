import 'package:bluestone/src/Pages/calendars/calendarDisplay.dart';
import 'package:bluestone/src/Pages/cards/bulletDisplay.dart';
import 'package:bluestone/src/Pages/cards/checkboxDisplay.dart';
import 'package:bluestone/src/Pages/cards/stickyDisplay.dart';
import 'package:bluestone/src/Pages/welcomePage.dart';
import 'package:bluestone/src/components/firebaseContent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bluestone/src/components/extras.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.user}) : super(key: key);

  final FirebaseUser user;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// static final FirebaseUser user = MyHomePage
enum CardChoices { STICKY, BULLET, CHECKBOX }

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _searchBar = new TextEditingController();
  bool haveResults = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        //bottomNavigationBar: BottomAppBar(),
        appBar: AppBar(
          title: Text(
            widget.title,
            textAlign: TextAlign.left,
          ),
          flexibleSpace: Container(
            alignment: Alignment(0.85, -0.3),
            child: IconButton(
              icon: Icon(Icons.person),
              iconSize: 35.0,
              color: Colors.white,
              tooltip: "${widget.user.email} is logged in.",
              onPressed: () {
                var thing = new SimpleDialog(
                  title: Text("Select a User Account"),
                  children: <Widget>[
                    SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context);
                          return showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return new AlertDialog(
                                  content:
                                      new Text("Would you like to log out?"),
                                  actions: <Widget>[
                                    new FlatButton(
                                      child: new Text("No"),
                                      onPressed: () {
                                        print("User chose not to log out.");
                                        Navigator.pop(context);
                                      },
                                    ),
                                    new FlatButton(
                                      child: new Text("Yes"),
                                      onPressed: () {
                                        print(
                                            "Current user: ${widget.user.email} has logged out.");
                                        CurrentLoggedInUser.user = null;
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    WelcomePage()));
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.person),
                            Text("${widget.user.email}"),
                          ],
                        )),
                  ],
                );
                assert(AlertDialog != null);
                return showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return thing;
                    });
              },
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Cards",
              ),
              Tab(
                text: "Calendars",
              ),
              Tab(
                text: "Search",
              ),
            ],
          ),
        ),
        backgroundColor: ThemeSettings.themeData.backgroundColor,
        body: TabBarView(
          children: [
            FutureBuilder(
              future: getCardPost(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return new Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return new Text(" Error: Connnection Timeout. ");
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length + 1,
                    itemBuilder: (_, index) {
                      return (index == snapshot.data.length)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Container(
                                margin:
                                    EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                                decoration: BoxDecoration(
                                    color: ThemeSettings.themeData.accentColor,
                                    shape: BoxShape.rectangle),
                                child: FlatButton.icon(
                                  label: Expanded(
                                    child: Text(
                                      "Add A New Card",
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.add,
                                    size: 75.0,
                                  ),
                                  onPressed: () {
                                    print("New card button pressed.");
                                    showDialogBoxCard();
                                  },
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Container(
                                margin:
                                    EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                                decoration: BoxDecoration(
                                    color: ThemeSettings.themeData.accentColor,
                                    shape: BoxShape.rectangle),
                                child: FlatButton.icon(
                                  clipBehavior: Clip.antiAlias,
                                  label: Expanded(
                                    child: Text(
                                      "${snapshot.data[index].data["title"]}",
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.view_headline,
                                    size: 75.0,
                                  ),
                                  onPressed: () {
                                    print(
                                        "${snapshot.data[index].data["title"]} was tapped. DocumentID: ${snapshot.data[index].documentID}");
                                    if (snapshot.data[index].data["type"] ==
                                        "Sticky") {
                                      FirestoreContent.stickySnap =
                                          snapshot.data[index];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StickyDisplay()));
                                    } else if (snapshot
                                            .data[index].data["type"] ==
                                        "Bullet") {
                                      FirestoreContent.bulletSnap =
                                          snapshot.data[index];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BulletPage()));
                                    } else if (snapshot
                                            .data[index].data["type"] ==
                                        "Checkbox") {
                                      FirestoreContent.checkboxSnap =
                                          snapshot.data[index];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CheckboxPage()));
                                    }
                                  },
                                ),
                              ),
                            );
                    },
                  );
                }
              },
            ),
            FutureBuilder(
              future: getCalendarPost(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return new Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return new Text(" Error: Connnection Timeout. ");
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length + 1,
                    itemBuilder: (_, index) {
                      return (index == snapshot.data.length)
                          ? Container(
                              margin:
                                  EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                              decoration: BoxDecoration(
                                  color: ThemeSettings.themeData.accentColor,
                                  shape: BoxShape.rectangle),
                              child: FlatButton.icon(
                                label: Expanded(
                                  child: Text(
                                    "Add A New Calendar",
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ),
                                icon: Icon(Icons.add, size: 75.0),
                                onPressed: () async {
                                  print("New calendar button pressed.");
                                  FirestoreContent.setCollectionReference(
                                      "Calendar");
                                  Map<String, dynamic> mainData =
                                      <String, dynamic>{
                                    "title": "New Calendar",
                                    "visibility": false,
                                    "scope": false,
                                  };
                                  Map<String, dynamic> duplicateData =
                                      <String, dynamic>{
                                    "title": "New Calendar",
                                    "visibility": false,
                                    "scope": false,
                                    "creatorRef":
                                        "${CurrentLoggedInUser.user.uid}",
                                  };
                                  FirestoreContent.calendarDoc =
                                      await FirestoreContent.mainData
                                          .add(mainData)
                                          .whenComplete(() {
                                    setState(() {});
                                  });
                                  print(
                                      "New Calendar Created. Document ID: ${FirestoreContent.calendarDoc.documentID}");
                                  FirestoreContent.setDocumentReference(
                                      "${FirestoreContent.calendarDoc.documentID}",
                                      "Calendar");
                                  await FirestoreContent.duplicateData
                                      .setData(duplicateData)
                                      .whenComplete(() {
                                    setState(() {});
                                  });
                                  print("Duplicate Document Entry Added.");
                                  FirestoreContent.calendarSnap =
                                      await FirestoreContent.calendarDoc.get();
                                  navigateToCalendar(FirestoreContent
                                      .calendarSnap.data["title"]);
                                },
                              ),
                            )
                          : Container(
                              margin:
                                  EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                              decoration: BoxDecoration(
                                  color: ThemeSettings.themeData.accentColor,
                                  shape: BoxShape.rectangle),
                              child: FlatButton.icon(
                                label: Expanded(
                                  child: Text(
                                    "${snapshot.data[index].data["title"]}",
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.calendar_today,
                                  size: 75.0,
                                ),
                                onPressed: () {
                                  print(
                                      "${snapshot.data[index].data["title"]} was tapped. DocumentID: ${snapshot.data[index].documentID}");
                                  FirestoreContent.calendarSnap =
                                      snapshot.data[index];
                                  FirestoreContent.calendarDoc =
                                      Firestore.instance.document(
                                          "Calendars/Live/UIDs/${CurrentLoggedInUser.user.uid}/CalendarIDs/${FirestoreContent.calendarSnap.documentID}");
                                  navigateToCalendar(
                                      snapshot.data[index].data["title"]);
                                },
                              ),
                            );
                    },
                  );
                }
              },
            ),
            Column(children: <Widget>[
              Container(
                margin: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _searchBar,
                        maxLength: 18,
                        enableInteractiveSelection: true,
                        decoration: InputDecoration(icon: Icon(Icons.search)),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Flexible(
                      child: RaisedButton(
                        child: Icon(Icons.send),
                        onPressed: () {
                          haveResults = !haveResults;
                          setState(() {});
                        },
                        elevation: 2,
                        color: ThemeSettings.themeData.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              (haveResults)
                  ? Expanded(
                      child: FutureBuilder(
                        future: searchResults(),
                        builder: (_, snapshot) {
                          if (snapshot.data.hashCode == 481762257) {
                            return Text("No Results found");
                          } else {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return new Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.none) {
                              return new Text(" Error: Connnection Timeout. ");
                            } else {
                              return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (_, index) {
                                  return Container(
                                    margin: EdgeInsets.fromLTRB(
                                        15.0, 20.0, 15.0, 20.0),
                                    decoration: BoxDecoration(
                                        color:
                                            ThemeSettings.themeData.accentColor,
                                        shape: BoxShape.rectangle),
                                    child: FlatButton.icon(
                                      label: Expanded(
                                        child: Text(
                                          "${snapshot.data[index].data["title"]}",
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                      ),
                                      icon:
                                          (snapshot.data[index].data["type"] ==
                                                      "Sticky" ||
                                                  snapshot.data[index]
                                                          .data["type"] ==
                                                      "Bullet" ||
                                                  snapshot.data[index]
                                                          .data["type"] ==
                                                      "Checkbox")
                                              ? Icon(
                                                  Icons.view_headline,
                                                  size: 75.0,
                                                )
                                              : Icon(
                                                  Icons.calendar_today,
                                                  size: 75.0,
                                                ),
                                      onPressed: () {
                                        print(
                                            "${snapshot.data[index].data["title"]} was tapped. DocumentID: ${snapshot.data[index].documentID}");
                                        switch (
                                            snapshot.data[index].data["type"]) {
                                          case "Sticky":
                                            FirestoreContent.stickySnap =
                                                snapshot.data[index];
                                            FirestoreContent.stickyDoc =
                                                Firestore.instance.document(
                                                    "Cards/Live/UIDs/${CurrentLoggedInUser.user.uid}/CardIDs/${FirestoreContent.stickySnap.documentID}");
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StickyDisplay()));
                                            break;
                                          case "Bullet":
                                            FirestoreContent.bulletSnap =
                                                snapshot.data[index];
                                            FirestoreContent.bulletDoc =
                                                Firestore.instance.document(
                                                    "Cards/Live/UIDs/${CurrentLoggedInUser.user.uid}/CardIDs/${FirestoreContent.bulletSnap.documentID}");
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BulletPage()));
                                            break;
                                          case "Checkbox":
                                            FirestoreContent.checkboxSnap =
                                                snapshot.data[index];
                                            FirestoreContent.checkboxDoc =
                                                Firestore.instance.document(
                                                    "Cards/Live/UIDs/${CurrentLoggedInUser.user.uid}/CardIDs/${FirestoreContent.checkboxSnap.documentID}");
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CheckboxPage()));
                                            break;
                                          default:
                                            FirestoreContent.calendarSnap =
                                                snapshot.data[index];
                                            FirestoreContent.calendarDoc =
                                                Firestore.instance.document(
                                                    "Calendars/Live/UIDs/${CurrentLoggedInUser.user.uid}/CalendarIDs/${FirestoreContent.calendarSnap.documentID}");
                                            navigateToCalendar(snapshot
                                                .data[index].data["title"]);
                                        }
                                      },
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    )
                  : Expanded(
                      child: Text(
                        "Search For Calendars and Cards here.",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    )
            ]),
          ],
        ),
      ),
    );
  }

  Future<Null> showDialogBoxCard() async {
    FirestoreContent.setCollectionReference("Cards");
    switch (await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: Text("Select a Card Type"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, CardChoices.STICKY);
              },
              child: const Text("Sticky"),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, CardChoices.BULLET);
              },
              child: const Text("Bullet"),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, CardChoices.CHECKBOX);
              },
              child: const Text("Checkbox"),
            ),
          ],
        );
      },
    )) {
      case CardChoices.STICKY:
        print("Card Type - Sticky - was selected.");
        Map<String, dynamic> mainData = <String, dynamic>{
          "title": "New Sticky Card",
          "textBody": "Tap the edit icon then enter text here!",
          "visibility": false,
          "type": "Sticky",
          "scope": false,
        };
        Map<String, dynamic> duplicateData = <String, dynamic>{
          "title": "New Sticky Card",
          "visibility": false,
          "type": "Sticky",
          "scope": false,
          "creatorRef": "${CurrentLoggedInUser.user.uid}"
        };
        FirestoreContent.stickyDoc =
            await FirestoreContent.mainData.add(mainData).whenComplete(() {
          setState(() {});
        });
        print(
            "New Card Created. Document ID: ${FirestoreContent.stickyDoc.documentID}");
        FirestoreContent.setDocumentReference(
            "${FirestoreContent.stickyDoc.documentID}", "Cards");
        await FirestoreContent.duplicateData
            .setData(duplicateData)
            .whenComplete(() {
          setState(() {});
        });
        print("Duplicate Document Entry Added.");
        FirestoreContent.stickySnap = await FirestoreContent.stickyDoc.get();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => StickyDisplay()));
        break;

      case CardChoices.BULLET:
        print("Card Type - Bullet - was selected.");
        Map<String, dynamic> mainData = <String, dynamic>{
          "title": "New Bullet Card",
          "visibility": false,
          "type": "Bullet",
          "scope": false,
        };
        Map<String, dynamic> duplicateData = <String, dynamic>{
          "title": "New Bullet Card",
          "visibility": false,
          "type": "Bullet",
          "scope": false,
          "creatorRef": "${CurrentLoggedInUser.user.uid}"
        };
        FirestoreContent.bulletDoc =
            await FirestoreContent.mainData.add(mainData).whenComplete(() {
          setState(() {});
        });
        print(
            "New Card Created. Document ID: ${FirestoreContent.bulletDoc.documentID}");
        FirestoreContent.setDocumentReference(
            "${FirestoreContent.bulletDoc.documentID}", "Cards");
        await FirestoreContent.duplicateData
            .setData(duplicateData)
            .whenComplete(() {
          setState(() {});
        });
        print("Duplicate Document Entry Added.");
        FirestoreContent.bulletSnap = await FirestoreContent.bulletDoc.get();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BulletPage()));

        break;

      case CardChoices.CHECKBOX:
        print("Card Type - Checkbox - was selected.");
        Map<String, dynamic> mainData = <String, dynamic>{
          "title": "New Checkbox Card",
          "visibility": false,
          "type": "Checkbox",
          "scope": false,
        };
        Map<String, dynamic> duplicateData = <String, dynamic>{
          "title": "New Checkbox Card",
          "visibility": false,
          "type": "Checkbox",
          "scope": false,
          "creatorRef": "${CurrentLoggedInUser.user.uid}"
        };
        FirestoreContent.checkboxDoc =
            await FirestoreContent.mainData.add(mainData).whenComplete(() {
          setState(() {});
        });
        print(
            "New Card Created. Document ID: ${FirestoreContent.checkboxDoc.documentID}");
        FirestoreContent.setDocumentReference(
            "${FirestoreContent.checkboxDoc.documentID}", "Cards");
        await FirestoreContent.duplicateData
            .setData(duplicateData)
            .whenComplete(() {
          setState(() {});
        });
        print("Duplicate Document Entry Added.");
        FirestoreContent.checkboxSnap =
            await FirestoreContent.checkboxDoc.get();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CheckboxPage()));

        break;
    }
  }

  void navigateToCalendar(String title) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CalendarDisplay(
                  title: title,
                ),
            fullscreenDialog: true));
  }

  Future getCardPost() async {
    var collectionOfCards = await Firestore.instance
        .collection("Cards/Live/UIDs/${CurrentLoggedInUser.user.uid}/CardIDs/")
        .getDocuments();
    return collectionOfCards.documents;
  }

  Future getCalendarPost() async {
    var collectionOfCalendars = await Firestore.instance
        .collection(
            "Calendars/Live/UIDs/${CurrentLoggedInUser.user.uid}/CalendarIDs/")
        .getDocuments();
    return collectionOfCalendars.documents;
  }

  Future searchResults() async {
    QuerySnapshot cardRef = await Firestore.instance
        .collection("Cards/Live/All")
        .where("title", isEqualTo: _searchBar.text)
        .getDocuments();
    QuerySnapshot calendarRef = await Firestore.instance
        .collection("Calendars/Live/All")
        .where("title", isEqualTo: _searchBar.text)
        .getDocuments();

    if (cardRef.documents.length != 0 && calendarRef.documents.length != 0) {
      cardRef.documents.addAll(calendarRef.documents);
    } else if (cardRef.documents.length != 0 &&
        calendarRef.documents.length == 0) {
      cardRef.documents.removeWhere((doc) =>
          doc.data["creatorRef"] == CurrentLoggedInUser.user.uid ||
          doc.data["visibility"] == false);
      return cardRef.documents;
    } else if (cardRef.documents.length == 0 &&
        calendarRef.documents.length != 0) {
      calendarRef.documents.removeWhere((doc) =>
          doc.data["creatorRef"] == CurrentLoggedInUser.user.uid ||
          doc.data["visibility"] == false);
      return calendarRef.documents;
    } else {
      return Future;
    }
  }

  Icon iconMapping() {
    // Make switch case for icons to be saved in database

    return Icon(Icons.developer_mode);
  }
}
