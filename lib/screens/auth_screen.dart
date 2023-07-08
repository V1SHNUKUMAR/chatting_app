import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String username,
    String password,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final ref = FirebaseStorage.instance
            .ref()
            .child("user_image")
            .child(authResult.user.uid + ".jpg");
        await ref.putFile(image).whenComplete(() => image);

        final url = await ref.getDownloadURL();
        // final currentUser = FirebaseAuth.instance.currentUser;
        // final groupId = FirebaseFirestore.instance
        //     .collection("groups")
        //     .doc(currentUser.uid);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(authResult.user.uid)
            .set({
          "username": username,
          "email": email,
          "image_url": url,
          "groupId": "",
          "groups": [],
        });
      }
    } on FirebaseAuthException catch (err) {
      if (err.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.message),
          backgroundColor: Theme.of(ctx).errorColor,
        ));
      }
      setState(() {
        _isLoading = false;
      });
    }
    // catch (err) {
    //   // this shows the error: [firebase_auth/unknown] Given String is empty or null
    //   print(err);
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(err.toString()),
    //     backgroundColor: Theme.of(ctx).errorColor,
    //   ));
    //   // debugPrintStack();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //   colors: [Color(0xff8b96d6), Color(0xff101517)],
              //   stops: [0, 1],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              gradient: RadialGradient(
                colors: [
                  // Color.fromARGB(255, 86, 76, 175),
                  Colors.redAccent,
                  Color.fromARGB(255, 50, 100, 187),
                  Color(0xff101517),
                ],
                radius: 2,
                center: Alignment(
                  -1.0,
                  -1.0,
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                height: size.height,
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(children: [
                        Icon(
                          Icons.message_rounded,
                          size: 50,
                          color: Colors.white.withOpacity(.9),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Group Chat App",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white.withOpacity(.9)),
                        ),
                      ]),
                    ),
                    AuthForm(_submitAuthForm, _isLoading),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
