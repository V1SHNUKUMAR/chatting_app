import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/chat/message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({Key key, @required this.groupId}) : super(key: key);
  final String groupId;

  Future<User> currentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          currentUser(), // <---- here shows the error future: FirebaseAuth.instance.currentUser()
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        User user = FirebaseAuth.instance.currentUser;
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("groups")
                .doc(groupId) //<-- here should be groupId
                .collection("messages")
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.data == null) {
                return Center(
                  child: const Text("No messages here"),
                );
              } else if (chatSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                var collection = FirebaseFirestore.instance
                    .collection("groups")
                    .doc(groupId)
                    .collection("messages");
                var userRef = collection.get();
                var id = userRef.then((value) => collection.doc(user.uid).id);

                final chatDocs = chatSnapshot.data.docs;
                print(chatDocs);
                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (BuildContext context, int index) =>
                      MessageBubble(
                    chatDocs[index]["text"],
                    chatDocs[index]["username"],
                    chatDocs[index]["userImage"],
                    chatDocs[index]["userId"] == futureSnapshot.data.uid,
                    chatDocs[index]["groupId"],
                    // chatDocs[index]["userId"] == futureSnapshot.data.uid,

                    // key: ValueKey(chatDocs[index].docId)
                    key: ValueKey(id),
                  ),
                );
              }
            });
      },
    );
  }
}
