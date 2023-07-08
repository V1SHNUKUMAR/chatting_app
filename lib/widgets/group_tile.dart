import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/chat_page.dart';
import 'package:flutter_complete_guide/screens/chat_screen.dart';

class GroupTile extends StatefulWidget {
  final String username;
  final String groupId;
  final String groupName;
  const GroupTile({Key key, this.username, this.groupId, this.groupName})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatPage(
            groupId: widget.groupId,
            groupName: widget.groupName,
            username: widget.username,
          ),
        ));
      },
      onLongPress: () => showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        context: context,
        builder: (context) {
          String groupIdName = "${widget.groupId}_${widget.groupName}";
          return DeleteWarning(
            groupIdName: groupIdName,
          );
        },
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
        padding: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(.2),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            // Divider(),
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Text(
                  widget.groupName.substring(0, 1).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
              title: Text(
                widget.groupName,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                "Join the conversation as ${widget.username}",
                style: TextStyle(color: Colors.white),
              ),
            ),
            // Divider(
            //   color: Colors.white.withOpacity(.2),
            // )
          ],
        ),
      ),
    );
  }
}

class DeleteWarning extends StatefulWidget {
  const DeleteWarning({
    Key key,
    @required this.groupIdName,
  }) : super(key: key);
  final String groupIdName;

  @override
  State<DeleteWarning> createState() => _DeleteWarningState();
}

class _DeleteWarningState extends State<DeleteWarning> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blueGrey[100], borderRadius: BorderRadius.circular(15)),
      height: MediaQuery.of(context).size.height * .25,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 10),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Delete",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(
              color: Colors.blueGrey,
            ),
          ],
        ),
        // SizedBox(
        //   height: 5,
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            "You won't be able to recover this chat. Do you still want to delete ?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.blueGrey[200],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  )),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    deleteChat(widget.groupIdName);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.black),
                  )),
            ),
          ],
        )
      ]),
    );
  }

  //delete method
  deleteChat(String groupIdName) async {
    final User user = FirebaseAuth.instance.currentUser;
    DocumentReference userDocumentReference =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot["groups"];

    if (groups.contains(groupIdName)) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove([groupIdName]),
      });
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Chat Deleted Successfully."),
      //   backgroundColor: Colors.blueGrey[100],
      // ));
    }
  }
}
