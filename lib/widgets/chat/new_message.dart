import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key key, @required groupId, @required username})
      : super(key: key);
  final String groupId = "";
  final String username = "";

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enteredMessage = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // void _sendMessage() async {
  //   final user = await FirebaseAuth.instance.currentUser;
  //   final userData = await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(user.uid)
  //       .get();
  //   if (!_enteredMessage.isEmpty) {
  //     FirebaseFirestore.instance
  //         .collection("groups")
  //         .doc(widget.groupId)
  //         .collection("messages")
  //         .add({
  //       "text": _enteredMessage.trim(),
  //       "createdAt": Timestamp.now(),
  //       "userId": user.uid,
  //       "username": userData["username"],
  //       "userImage": userData["image_url"],
  //     });
  //   }
  //   _enteredMessage = "";
  //   _controller.clear();
  // }

  _sendMessage() {
    if (_enteredMessage.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": _enteredMessage.trim(),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      child: Row(children: [
        Expanded(
            child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "Type a message here",
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
          ),
          onChanged: (value) {
            setState(() {
              _enteredMessage = value;
            });
          },
        )),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(30)),
          child: IconButton(
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
            icon: Icon(
              Icons.send_rounded,
              size: 23,
              color: Colors.white,
            ),
            color: Theme.of(context).primaryColor,
          ),
        )
      ]),
    );
  }
}
