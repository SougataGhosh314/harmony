import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class SentRequestTile extends StatefulWidget {
  final String uid, name;

  SentRequestTile({this.name, this.uid});

  @override
  _SentRequestTileState createState() =>
      _SentRequestTileState(uid: uid, name: name);
}

class _SentRequestTileState extends State<SentRequestTile> {
  final String uid, name;
  _SentRequestTileState({this.name, this.uid});

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
    String tileSubtitle = "Awaiting request acceptance";
    String buttonText = "Unsend";
    Color buttonColor = Colors.amber[300];
    bool isFriend = false,
        isInIncomingRequests = false,
        isInOutgoingRequests = true,
        isOther = false;

    return StreamBuilder<Object>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            AppUser userData = snapshot.data;

            if (userData.friends.contains(uid)) {
              isFriend = true;
              isOther = false;
              isInOutgoingRequests = false;
              isInIncomingRequests = false;
              tileSubtitle = "Friend";
              buttonText = "Unfriend";
              buttonColor = Colors.red[300];
            } else if (userData.incomingRequests.contains(uid)) {
              isFriend = false;
              isOther = false;
              isInOutgoingRequests = false;
              isInIncomingRequests = true;
              tileSubtitle = "Wants to be your friend";
              buttonText = "Accept";
              buttonColor = Colors.green[300];
            } else if (userData.outgoingRequests.contains(uid)) {
              isFriend = false;
              isOther = false;
              isInOutgoingRequests = true;
              isInIncomingRequests = false;
              tileSubtitle = "Awaiting request acceptance";
              buttonText = "Unsend";
              buttonColor = Colors.amber[300];
            } else {
              isFriend = false;
              isOther = true;
              isInOutgoingRequests = false;
              isInIncomingRequests = false;
              tileSubtitle = "Person";
              buttonText = "Send request";
              buttonColor = Colors.black26;
            }

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
                  title: Text(
                    widget.name,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  subtitle: Text(
                    tileSubtitle,
                    style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 12),
                  ),
                  trailing: FlatButton(
                    color: buttonColor,
                    child: Text(
                      buttonText,
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      // unsend invite here
                      if (isOther) {
                        await DatabaseService(uid: user.uid).sendRequest(uid);
                        Fluttertoast.showToast(
                          msg: "Request sent",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                        );
                        //Navigator.pop(context);
                      } else if (isFriend) {
                        await DatabaseService(uid: user.uid).unFriend(uid);
                        Fluttertoast.showToast(
                          msg: "Removed friend",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                        );
                        //Navigator.pop(context);
                      } else if (isInIncomingRequests) {
                        await DatabaseService(uid: user.uid).acceptRequest(uid);
                        Fluttertoast.showToast(
                          msg: "Added friend",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                        );
                        //Navigator.pop(context);
                      } else if (isInOutgoingRequests) {
                        await DatabaseService(uid: user.uid).unSendRequest(uid);
                        Fluttertoast.showToast(
                          msg: "Request was unsent",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                        );
                        //Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
