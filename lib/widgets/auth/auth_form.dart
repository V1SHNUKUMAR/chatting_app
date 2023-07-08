import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/pickers/user_image_picker.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  File userImageFile;

  var _isLogin = true;
  var _userEmail = "";
  var _userName = "";
  var _userPassword = "";

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please pick an image"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userName.trim(),
        _userPassword.trim(),
        userImageFile,
        _isLogin,
        context,
      );

      //Values will be used to send auth request to firebase.
    }
  }

  void pickedImage(File image) {
    userImageFile = image;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
        color: Colors.white.withOpacity(.5),
        elevation: 0,
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isLogin ? "Welcome Back" : "Create New Account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 22,
                ),
                if (!_isLogin) UserImagePicker(pickedImage),
                if (!_isLogin)
                  SizedBox(
                    height: 16,
                  ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  key: ValueKey("email"),
                  validator: (value) {
                    if (value.isEmpty || !value.contains("@")) {
                      return "Please enter a valid email address.";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: "Email address",
                    // border: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(50)),
                    // contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                  ),
                  onChanged: (value) {
                    _userEmail = value;
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                if (!_isLogin)
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    key: ValueKey("username"),
                    validator: (value) {
                      if (value.isEmpty || value.length < 4) {
                        return "Invalid username";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: "Username",
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(50)),
                      // contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                    ),
                    onChanged: (value) {
                      _userName = value;
                    },
                  ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 18),
                  key: ValueKey("password"),
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return "Password must be atleast 7 characters long.";
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.key),
                    labelText: "Password",
                    // border: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(50)),
                    // contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                  ),
                  onChanged: (value) {
                    _userPassword = value;
                  },
                ),
                SizedBox(height: 24),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  ElevatedButton(
                    onPressed: _trySubmit,
                    child: Text(
                      _isLogin ? "Login" : "Create account",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      backgroundColor: Colors.blueAccent,
                      // backgroundColor: Colors.redAccent,
                      minimumSize: Size.fromHeight(45),
                      elevation: 0,
                      // shadowColor: Colors.red,
                    ),
                  ),
                // InkWell(
                //     onTap: () => _trySubmit,
                //     child: Row(
                //       children: [
                //         Expanded(
                //           child: Container(
                //             alignment: Alignment.center,
                //             padding: EdgeInsets.symmetric(vertical: 12),
                //             decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(30),
                //                 gradient: LinearGradient(
                //                   colors: [
                //                     // Color.fromARGB(255, 86, 76, 175),
                //                     Colors.redAccent,
                //                     Color.fromARGB(255, 50, 100, 187),
                //                     Color(0xff101517),
                //                   ],
                //                   // radius: 2,
                //                   // center: Alignment(
                //                   //   -1.0,
                //                   //   -1.0,
                //                   // ),
                //                 )),
                //             child: Text(
                //               _isLogin ? "Login" : "Create account",
                //               style: TextStyle(
                //                   color: Colors.white, fontSize: 20),
                //             ),
                //           ),
                //         ),
                //       ],
                //     )),
                if (!widget.isLoading)
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin
                          ? "Create New Account"
                          : "I Already Have An Account"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
