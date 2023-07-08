import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final String time;
  const MessageTile({
    Key key,
    @required this.message,
    @required this.sender,
    @required this.sentByMe,
    @required this.time,
  }) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   padding: EdgeInsets.only(
    //     top: 4,
    //     bottom: 4,
    //     left: widget.sentByMe ? 0 : 24,
    //     right: widget.sentByMe ? 24 : 0,
    //   ),
    //   alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
    //   child: Container(
    //     margin: widget.sentByMe
    //         ? EdgeInsets.only(left: 80)
    //         : EdgeInsets.only(right: 80),
    //     padding: EdgeInsets.only(
    //       top: 17,
    //       bottom: 17,
    //       left: 20,
    //       right: 20,
    //     ),
    //     decoration: BoxDecoration(
    //       color: widget.sentByMe
    //           ? Colors.blueGrey[100]
    //           : Theme.of(context).secondaryHeaderColor,
    //       borderRadius: BorderRadius.only(
    //           topLeft: Radius.circular(20),
    //           topRight: Radius.circular(20),
    //           bottomLeft:
    //               !widget.sentByMe ? Radius.circular(0) : Radius.circular(20),
    //           bottomRight:
    //               widget.sentByMe ? Radius.circular(0) : Radius.circular(20)),
    //     ),
    //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //       Text(
    //         widget.sender.toUpperCase(),
    //         textAlign: TextAlign.center,
    //         style: TextStyle(
    //           fontSize: 14,
    //           fontWeight: FontWeight.bold,
    //           color: !widget.sentByMe ? Colors.white : Colors.black,
    //         ),
    //       ),
    //       SizedBox(
    //         height: 8,
    //       ),
    //       Text(
    //         widget.message,
    //         textAlign: TextAlign.left,
    //         style: TextStyle(
    //           fontSize: 16,
    //           color: !widget.sentByMe ? Colors.white : Colors.black,
    //         ),
    //       )
    //     ]),
    //   ),
    // );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      child: Column(
        children: [
          ChatBubble(
            elevation: 0,
            backGroundColor: !widget.sentByMe
                ? Colors.indigo.withOpacity(.5)
                : Colors.white.withOpacity(.7),
            clipper: ChatBubbleClipper5(
                // nipSize: 5,
                radius: 20,
                type: widget.sentByMe
                    ? BubbleType.sendBubble
                    : BubbleType.receiverBubble),
            alignment:
                widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.sender,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.sentByMe ? Colors.black : Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      widget.message,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.sentByMe ? Colors.black : Colors.white,
                      ),
                    ),
                  ]),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: widget.sentByMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Text(
                  widget.time,
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey[300]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
