import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/chat/message_tile.dart';
import 'package:flutter_complete_guide/widgets/chat/messages.dart';
import 'package:flutter_complete_guide/widgets/chat/new_message.dart';

import 'group_info_screen.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String username;

  const ChatScreen(
      {Key key,
      @required this.groupId,
      @required this.groupName,
      @required this.username})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String admin = "";
  Stream<QuerySnapshot> chats;

  @override
  void initState() {
    // TODO: implement initState
    getChatAndAdmin();
    super.initState();
  }

  getChatAndAdmin() {
    getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });

    getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  //getting the chats
  getChats(String groupId) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .orderBy("createdAt")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d =
        FirebaseFirestore.instance.collection("groups").doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot["admin"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => GroupInfoScreen(
                    adminName: admin,
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                  ),
                ));
              },
              icon: Icon(
                Icons.info_outlined,
                size: 30,
              ))
          // DropdownButton(
          //   icon: Icon(
          //     Icons.more_vert,
          //     color: Theme.of(context).primaryIconTheme.color,
          //   ),
          //   items: [
          //     DropdownMenuItem(
          //       child: Container(
          //         child: Row(children: [
          //           Icon(
          //             Icons.exit_to_app,
          //             color: Colors.black,
          //           ),
          //           SizedBox(width: 8),
          //           Text("Logout")
          //         ]),
          //       ),
          //       value: "logout",
          //     ),
          //   ],
          //   onChanged: (itemidentifier) {
          //     if (itemidentifier == "logout") {
          //       FirebaseAuth.instance.signOut();
          //     }
          //   },
          // )
        ],
      ),
      body: Container(
        child: Column(children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Messages(),
          )),
          NewMessage(
            groupId: widget.groupId,
          ),
        ]),
      ),
    );
  }
}
