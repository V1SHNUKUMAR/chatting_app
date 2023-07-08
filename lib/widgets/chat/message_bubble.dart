import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
    this.message,
    this.username,
    this.userImage,
    this.isMe,
    this.groupId, {
    this.key,
  });

  final Key key;
  final String message;
  final String username;
  final bool isMe;
  final String userImage;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // SizedBox(
        //   height: 100,
        // ),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.blueGrey[100]
                    : Theme.of(context).secondaryHeaderColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft:
                        !isMe ? Radius.circular(0) : Radius.circular(20),
                    bottomRight:
                        isMe ? Radius.circular(0) : Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: isMe ? 18 : 10,
                right: !isMe ? 18 : 10,
              ),
              margin: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: isMe ? 30 : 10,
                  right: !isMe ? 30 : 10),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.black : Colors.white,
                    ),
                  ),
                  // Divider(
                  //   color: isMe ? Colors.blueGrey : Colors.white,
                  // ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    message ?? "",
                    style: TextStyle(
                      color: isMe ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage(userImage),
            ),
          ],
        ),
      ],
    );

    // clipBehavior: Clip.none,
  }
}
