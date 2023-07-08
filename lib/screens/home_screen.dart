import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/auth_screen.dart';
import 'package:flutter_complete_guide/screens/profile_screen.dart';
import 'package:flutter_complete_guide/screens/search_screen.dart';
import 'package:flutter_complete_guide/widgets/group_tile.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  String username = "";
  String email = "";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String groupName = "";
  Stream groups;
  Map<String, dynamic> userData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      gettingUserDetails();
    });
  }

  String getGroupId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getGroupName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  User user = FirebaseAuth.instance.currentUser;
  gettingUserDetails() async {
    final userDetails = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    // final username = await userDetails.data()["username"];
    // final email = await userDetails.data()["email"];
    if (userDetails != null) {
      setState(() {
        userData = userDetails.data();
        // widget.username = username;
        // widget.email = email;
      });
    }

    //getting the list of snapshots in our stream
    final userChatSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots();

    setState(() {
      groups = userChatSnapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Chats",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchScreen(),
              ));
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      drawer: SafeArea(
        child: Drawer(
          backgroundColor: Color(0xff101517),
          width: MediaQuery.of(context).size.width * 0.7,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 60, horizontal: 16),
            children: [
              // Icon(
              //   Icons.account_circle,
              //   size: 120,
              //   color: Colors.grey[700],
              // ),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  userData != null ? userData["image_url"] ?? "" : "",
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                userData != null ? userData["username"] ?? "" : "",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              SizedBox(
                height: 30,
              ),
              Divider(
                height: 2,
              ),
              ListTile(
                onTap: () {},
                selectedColor: Theme.of(context).primaryColor,
                selected: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                leading: Icon(
                  Icons.group,
                  size: 30,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                title: Text(
                  "Chats",
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 18,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userData["username"],
                          userData["email"], userData["image_url"]),
                    ),
                  );
                },
                selected: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                leading: Icon(
                  Icons.account_box_outlined,
                  size: 25,
                  color: Colors.blueGrey,
                ),
                title: Text(
                  "My Profile",
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
              ),
              ListTile(
                onTap: () async {
                  showDialog(
                    // barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.blueGrey[100],
                        title: Text(
                          "Logout",
                        ),
                        content: Text("Are you sure you want to logout?"),
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
                                FirebaseAuth.instance.signOut();
                                // Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => AuthScreen(),
                                ));
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
                selectedColor: Theme.of(context).primaryColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                leading: Icon(
                  Icons.exit_to_app,
                  size: 25,
                  color: Colors.blueGrey,
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(
          colors: [Color.fromARGB(255, 86, 76, 175), Color(0xff101517)],
          stops: [0, 1],
          center: Alignment.centerRight,
          radius: 1,
        )),
        child: groupList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  createGroup(String username, String id, String groupName) async {
    print("username : ${userData["username"]}");
    DocumentReference groupDocumentReference =
        await FirebaseFirestore.instance.collection("groups").add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_${userData["username"]}",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    //updating the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${user.uid}_${userData["username"]}"]),
      "groupId": groupDocumentReference.id,
    });

    //updating groups in users collection
    DocumentReference userDocumentReference =
        FirebaseFirestore.instance.collection("users").doc(user.uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"]),
    });
  }

  popUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.blueGrey[100],
              title: Text(
                'Create a group',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : TextField(
                          style: TextStyle(fontSize: 18),
                          onChanged: (value) {
                            setState(() {
                              groupName = value;
                            });
                          },
                          decoration:
                              InputDecoration(hintText: "Type Group name..."),
                        )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel")),
                ElevatedButton(
                    onPressed: () async {
                      if (groupName != null) {
                        setState(() {
                          isLoading = true;
                        });
                      }
                      createGroup(widget.username,
                          FirebaseAuth.instance.currentUser.uid, groupName);
                      isLoading = false;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Group created successfully"),
                        backgroundColor: Colors.green,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    child: Text("Create"))
              ],
            );
          },
        );
      },
    );
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData &&
            snapshot.data['groups'] != null &&
            snapshot.data["groups"].length != 0) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 30),
            itemCount: snapshot.data["groups"].length,
            itemBuilder: (BuildContext context, int index) {
              int reverseIndex = snapshot.data["groups"].length - index - 1;
              return GroupTile(
                username: snapshot.data["username"],
                groupId: getGroupId(snapshot.data["groups"][reverseIndex]),
                groupName: getGroupName(snapshot.data["groups"][reverseIndex]),
              );
            },
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble,
                  size: 70,
                  color: Colors.white.withOpacity(.2),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  child: Text(
                    "Start chatting with friends by creating a group or by joining an existing one",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.3),
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
