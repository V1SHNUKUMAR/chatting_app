import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/chat_page.dart';
import 'package:flutter_complete_guide/screens/chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot searchSnapshot;
  bool hasUserSearched = false;
  String username = "";
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getGroupId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  User user = FirebaseAuth.instance.currentUser;

  getCurrentUserIdandName() async {
    final userDetails = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    username = await userDetails.data()["username"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: Text(
            "Search",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )),
      body: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(
          // colors: [Color.fromARGB(255, 86, 76, 175), Color(0xff101517)],
          colors: [Color(0xff334192), Color(0xff101517)],
          stops: [0, 1],
          center: Alignment.centerRight,
          radius: 1,
        )),
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => initiateSearchMethod(),
                    textInputAction: TextInputAction.done,
                    controller: searchController,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        hintText: "Search groups here...",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(.5),
                          fontSize: 20,
                        ),
                        border:
                            OutlineInputBorder(borderSide: BorderSide.none)),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ]),
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : groupList(),
          ],
        ),
      ),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.trim().isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await searchByName(searchController.text.trim()).then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  searchByName(String groupName) {
    return FirebaseFirestore.instance
        .collection("groups")
        .where("groupName", isEqualTo: groupName)
        .get();
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                username,
                searchSnapshot.docs[index]["groupId"],
                searchSnapshot.docs[index]["groupName"],
                searchSnapshot.docs[index]["admin"],
              );
            },
          )
        : Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 80,
                    color: Colors.grey.withOpacity(.5),
                  ),
                  Text(
                    "Search groups to join",
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                ],
              ),
            ),
          );
  }

  Widget groupTile(
      String username, String groupId, String groupName, String admin) {
    //function to check if user already in the groups
    joinedOrNot(groupName, groupId, username);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(.2),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        leading: CircleAvatar(
          radius: 30,
          child: Text(
            "${groupName.substring(0, 1).toUpperCase()}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        title: Text(
          groupName,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        subtitle: Text(
          "Admin: ${getName(admin)}",
          style: TextStyle(color: Colors.white),
        ),
        trailing: InkWell(
          onTap: () async {
            await toggleGroupJoin(groupId, groupName, username);
            if (isJoined) {
              setState(() {
                isJoined = !isJoined;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Successfully joined the group"),
                backgroundColor: Colors.green,
              ));
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      username: username),
                ));
              });
            } else {
              setState(() {
                isJoined = !isJoined;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Successfully left the group ${groupName}"),
                backgroundColor: Colors.red,
              ));
            }
          },
          child: isJoined
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black),
                  child: Text(
                    "Joined",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).secondaryHeaderColor),
                  child: Text(
                    "Join Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ),
      ),
    );
  }

  joinedOrNot(String groupName, String groupId, String username) async {
    await isUserJoined(groupName, groupId, username).then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Future<bool> isUserJoined(
      String groupName, String groupId, String username) async {
    DocumentReference userdocumentReference =
        await FirebaseFirestore.instance.collection("users").doc(user.uid);
    DocumentSnapshot documentSnapshot = await userdocumentReference.get();

    List<dynamic> groups = await documentSnapshot["groups"];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
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
