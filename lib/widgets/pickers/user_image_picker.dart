import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);
  final void Function(File pickedImage) imagePickFn;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File pickedImage;

  void pickImage() async {
    final picker = ImagePicker();
    final pickedImageFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    setState(() {
      pickedImage = File(pickedImageFile.path);
    });
    widget.imagePickFn(pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: pickedImage != null ? FileImage(pickedImage) : null,
          backgroundColor: Colors.blueGrey[200],
        ),
        TextButton.icon(
            onPressed: pickImage,
            icon: Icon(Icons.image),
            label: Text("Upload Image")),
      ],
    );
  }
}
