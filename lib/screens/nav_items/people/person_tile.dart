import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:provider/provider.dart';

class PersonTile extends StatefulWidget {
  final String uid, name;

  PersonTile({this.name, this.uid});

  @override
  _PersonTileState createState() => _PersonTileState(uid: uid, name: name);
}

class _PersonTileState extends State<PersonTile> {
  final String uid, name;
  _PersonTileState({this.name, this.uid});

  String profilePicFromDB = "";

  Future getDownloadURL(String uid) async {
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref();
    String imageName = "profile_images/" + "$uid" + ".png";
    print(imageName);
    String url = await ref.child(imageName).getDownloadURL();
    print("Url recieved: $url");
    setState(() {
      profilePicFromDB = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    String imageURL =
        "https://cdn.pixabay.com/photo/2013/08/26/11/04/quill-175980_960_720.png";

    if (profilePicFromDB == "") {
      getDownloadURL(uid);
    }

    if (profilePicFromDB != "") {
      imageURL = profilePicFromDB;
    }

    final user = Provider.of<AppUser>(context);

    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Card(
        margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageURL),
            radius: 25,
            backgroundColor: Colors.red,
          ),
          title: Text(widget.name),
          trailing: FlatButton(
            color: Colors.black26,
            child: Text(
              "Send request",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              // send invite here
              //print("mine: " + user.uid + " :: to Send to: " + uid);

              await DatabaseService(uid: user.uid).sendRequest(uid);
            },
          ),
        ),
      ),
    );
  }
}
