import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/home_screen.dart';

import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(this.username, this.email, this.image_url, {Key key})
      : super(key: key);
  final String username;
  final String email;
  final String image_url;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "My Profile",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                  backgroundImage: NetworkImage(widget.image_url ?? ""),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  widget.username,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  height: 2,
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ));
                  },
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  leading: Icon(
                    Icons.group,
                    size: 30,
                    color: Colors.blueGrey,
                  ),
                  title: Text(
                    "Chats",
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                ListTile(
                  selected: true,
                  selectedColor: Theme.of(context).secondaryHeaderColor,
                  onTap: () {},
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  leading: Icon(
                    Icons.account_box_outlined,
                    size: 28,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  title: Text(
                    "My Profile",
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 18,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () async {
                    showDialog(
                      barrierDismissible: false,
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  leading: Icon(
                    Icons.exit_to_app,
                    size: 28,
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
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
              gradient: RadialGradient(
            // colors: [Color.fromARGB(255, 86, 76, 175), Color(0xff101517)],
            colors: [Color(0xff334192), Color(0xff101517)],
            stops: [0, 1],
            center: Alignment.centerRight,
            radius: 1,
          )),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon(
                //   Icons.account_circle,
                //   size: 120,
                // ),
                SizedBox(
                  height: 50,
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.image_url),
                ),
                SizedBox(
                  height: 50,
                ),
                Column(
                  children: [
                    Text(
                      widget.username,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ]),
        ));
  }
}
