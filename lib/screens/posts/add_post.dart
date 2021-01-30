import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/constants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  File _imageFile;

  /// Cropper plugin
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    PickedFile selected = await ImagePicker().getImage(source: source);

    setState(() {
      _imageFile = File(selected.path);
    });
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
  }

  String textContent = "";
  String visibility = "friends";
  String mediaContentURL =
      "https://cdn.pixabay.com/photo/2013/08/26/11/04/quill-175980_960_720.png";

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Create post"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.photo_camera,
                        size: 30,
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.photo_library,
                        size: 30,
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      color: Colors.pink,
                    ),
                  ],
                ),
                if (_imageFile != null) ...[
                  Container(
                      padding: EdgeInsets.all(10),
                      height: 200,
                      width: 200,
                      child: Image.file(_imageFile)),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        color: Colors.white,
                        child: Icon(Icons.crop),
                        onPressed: _cropImage,
                      ),
                      FlatButton(
                        color: Colors.white,
                        child: Icon(Icons.refresh),
                        onPressed: _clear,
                      ),
                    ],
                  ),
                ],
                TextFormField(
                  initialValue: "",
                  keyboardType: TextInputType.multiline,
                  decoration: textInputDecoration.copyWith(
                      hintText: "Add text to your post"),
                  onChanged: (val) {
                    setState(() => {textContent = val});
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Visibility: "),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField(
                  dropdownColor: Colors.white70,
                  focusColor: Colors.blue[400],
                  value: visibility ?? "private",
                  decoration: textInputDecoration,
                  items: [
                    DropdownMenuItem(
                      value: "private",
                      child: Text("private"),
                    ),
                    DropdownMenuItem(
                      value: "friends",
                      child: Text("friends"),
                    ),
                    DropdownMenuItem(
                      value: "public",
                      child: Text("public"),
                    ),
                  ],
                  onChanged: (val) => setState(() => visibility = val),
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  color: Colors.black26,
                  child: Text("Post"),
                  onPressed: () async {
                    String postID = user.uid +
                        "_" +
                        DateTime.now().millisecondsSinceEpoch.toString();
                    String filePath = 'post_media/$postID.png';
                    try {
                      await firebase_storage.FirebaseStorage.instance
                          .ref()
                          .child(filePath)
                          .putFile(_imageFile);

                      String url = await firebase_storage
                          .FirebaseStorage.instance
                          .ref()
                          .child(filePath)
                          .getDownloadURL();

                      Post myPost = Post(
                          textContent: textContent,
                          visibility: visibility,
                          mediaContentURL: url,
                          creatorId: user.uid,
                          likes: [],
                          comments: [],
                          postId: user.uid +
                              "_" +
                              DateTime.now().millisecondsSinceEpoch.toString());

                      await DatabaseService(uid: user.uid).createPost(myPost);

                      Fluttertoast.showToast(
                        msg: "Post added",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      return e.toString();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
