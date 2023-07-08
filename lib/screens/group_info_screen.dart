import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/home_screen.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  User user = FirebaseAuth.instance.currentUser;

  GroupInfoScreen({
    Key key,
    @required this.groupId,
    @required this.adminName,
    @required this.groupName,
  }) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  Stream members;
  User user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    getGroupMembers(widget.groupId).then((value) {
      setState(() {
        members = value;
      });
    });
    super.initState();
  }

//get group members
  getGroupMembers(groupId) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .snapshots();
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getGroupId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Group Info",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.blueGrey[100],
                    title: Text(
                      "Leave Group",
                    ),
                    content: Text("Are you sure you want to leave the group?"),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            toggleGroupJoin(widget.groupId, widget.groupName,
                                    getName(widget.adminName))
                                .whenComplete(() {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ));
                            });
                          },
                          icon: Icon(
                            Icons.done_rounded,
                            color: Colors.green,
                            size: 30,
                          ))
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.exit_to_app,
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
            gradient: RadialGradient(
          colors: [Color(0xff334192), Color(0xff101517)],
          stops: [0, 1],
          center: Alignment.centerRight,
          radius: 1,
        )),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(.2),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(widget.groupName.toUpperCase().substring(0, 1)),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Group: ${widget.groupName}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(.9)),
                    ),
                    Text(
                      "Admin: ${getName(widget.adminName)}",
                      style: TextStyle(color: Colors.white.withOpacity(.9)),
                    )
                  ],
                )
              ]),
            ),
            memberList(),
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != null) {
              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: snapshot.data['members'].length,
                  // shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          child: Text(
                            getName(snapshot.data["members"][index])
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          getName(snapshot.data['members'][index]),
                          style: TextStyle(
                              color: Colors.white.withOpacity(.9),
                              fontSize: 17),
                        ),
                        subtitle: Text(
                          getGroupId(snapshot.data['members'][index]),
                          style: TextStyle(color: Colors.white.withOpacity(.9)),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: Text("No members"),
              );
            }
          } else {
            return Center(
              child: Text("No members"),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future toggleGroupJoin(
      String groupId, String groupName, String username) async {
    DocumentReference userDocumentReference =
        FirebaseFirestore.instance.collection("users").doc(user.uid);
    DocumentReference groupDocumentReference =
        FirebaseFirestore.instance.collection("groups").doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot["groups"];

    // if user has our groups -> then remove them or also in another part rejoin
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${user.uid}_$username"]),
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${user.uid}_$username"]),
      });
    }

    ;
  }
}
