import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/chat/message_tile.dart';
import 'package:flutter_complete_guide/widgets/chat/new_message.dart';
import 'package:intl/intl.dart';

import 'group_info_screen.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String username;

  const ChatPage(
      {Key key,
      @required this.groupId,
      @required this.groupName,
      @required this.username})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = new TextEditingController();
  var _enteredMessage = "";

  String admin = "";
  Stream<QuerySnapshot> chats;

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

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
      print("admin : $admin");
    });
  }

  //getting the chats
  getChats(String groupId) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d =
        FirebaseFirestore.instance.collection("groups").doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    String admin = documentSnapshot["admin"];
    return admin.substring(admin.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName), actions: [
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
      ]),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
          decoration: BoxDecoration(
              gradient: RadialGradient(
            // colors: [Color.fromARGB(255, 86, 76, 175), Color(0xff101517)],
            colors: [Color(0xff334192), Color(0xff101517)],
            stops: [0, 1],
            center: Alignment.centerRight,
            radius: 1,
          )),
          child: Column(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: chatMessages(),
                )),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _enteredMessage = value;
                              });
                            },
                            style: TextStyle(fontSize: 18),
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "Type a message here",
                              fillColor: Colors.white.withOpacity(.8),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              contentPadding:
                                  EdgeInsets.fromLTRB(15, 10, 15, 0),
                            ),
                            // onChanged: (value) {
                            //   setState(() {
                            //     _enteredMessage = value;
                            //   });
                            // },
                          )),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30)),
                            child: IconButton(
                              onPressed: _enteredMessage.trim().isEmpty
                                  ? null
                                  : sendMessage,
                              icon: Icon(
                                Icons.send_rounded,
                                size: 23,
                                color: Colors.white,
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        ]),
                  ),
                )
              ]),
        ),
      ),
    );
  }

  // sendMessage() {
  //   if (_controller.text.trim().isNotEmpty) {
  //     Map<String, dynamic> chatMessageMap = {
  //       "message": _controller.text.trim(),
  //       "sender": widget.username,
  //       "time": DateTime.now().millisecondsSinceEpoch,
  //     };

  //     // sendUserMessage(widget.groupId, chatMessageMap);
  //     // setState(() {
  //     //   _controller.clear();
  //     // });
  //   }
  // }
  void sendMessage() async {
    final user = await FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    Map<String, dynamic> chatMessageMap = {
      "message": _enteredMessage.trim(),
      "sender": widget.username,
      "time": DateTime.now().millisecondsSinceEpoch,
      "sentByMe": "",
    };
    if (_enteredMessage.trim().isNotEmpty) {
      FirebaseFirestore.instance
          .collection("groups")
          .doc(widget.groupId)
          .collection("messages")
          .add(chatMessageMap);
    }
    FirebaseFirestore.instance.collection("groups").doc(widget.groupId).update({
      "recentMessage": chatMessageMap["message"],
      "recentMessageSender": chatMessageMap["sender"],
      "recentMessageTime": chatMessageMap["time"].toString(),
    });
    _enteredMessage = "";
    _controller.clear();
  }

  // sendUserMessage(String groupId, Map<String, dynamic> chatMessageData) async {
  //   FirebaseFirestore.instance
  //       .collection("groups")
  //       .doc(groupId)
  //       .collection("messages")
  //       .add(chatMessageData);
  //   FirebaseFirestore.instance.collection("groups").doc(groupId).update({
  //     "recentMessage": chatMessageData["message"],
  //     "recentMessageSender": chatMessageData["sender"],
  //     "recentMessageTime": chatMessageData["createdAt"].toString(),
  //   });
  // }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            reverse: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              var rawTime = snapshot.data.docs[index]["time"];
              var time = DateTime.fromMillisecondsSinceEpoch(rawTime);
              String formattedTime = DateFormat("hh:mm a").format(time);
              return MessageTile(
                message: snapshot.data.docs[index]["message"],
                sender: snapshot.data.docs[index]["sender"],
                time: formattedTime,
                sentByMe:
                    widget.username == snapshot.data.docs[index]['sender'],
              );
            },
          );
        } else if (!snapshot.hasData) {
          Center(
            child: Text(
              "Say Hi !",
              style:
                  TextStyle(fontSize: 30, color: Colors.white.withOpacity(.5)),
            ),
          );
        }
        return Center(
          child: Text(
            "Say Hi !",
            style: TextStyle(fontSize: 30, color: Colors.white.withOpacity(.5)),
          ),
        );
      },
    );
  }
}
