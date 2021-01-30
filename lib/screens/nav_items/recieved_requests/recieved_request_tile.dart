import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class RecievedRequestTile extends StatefulWidget {
  final String uid, name;

  RecievedRequestTile({this.name, this.uid});

  @override
  _RecievedRequestTileState createState() =>
      _RecievedRequestTileState(uid: uid, name: name);
}

class _RecievedRequestTileState extends State<RecievedRequestTile> {
  final String uid, name;
  _RecievedRequestTileState({this.name, this.uid});

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
    String tileSubtitle = "Wants to be your friend";
    String buttonText = "Accept";
    Color buttonColor = Colors.green[300];
    bool isFriend = false,
        isInIncomingRequests = true,
        isInOutgoingRequests = false,
        isOther = false,
        VISIBILITY = false,
        extraTileVISIBILITY = true;

    return StreamBuilder<Object>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            AppUser userData = snapshot.data;

            if (!userData.incomingRequests.contains(uid)) {
              extraTileVISIBILITY = false;
              VISIBILITY = true;
            }

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
                child: Column(
                  children: [
                    ListTile(
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
                      trailing: Visibility(
                        visible: VISIBILITY,
                        child: FlatButton(
                          color: buttonColor,
                          child: Text(
                            buttonText,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (isOther) {
                              await DatabaseService(uid: user.uid)
                                  .sendRequest(uid);
                              Fluttertoast.showToast(
                                msg: "Request sent",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                              );
                              //Navigator.pop(context);
                            } else if (isFriend) {
                              await DatabaseService(uid: user.uid)
                                  .unFriend(uid);
                              Fluttertoast.showToast(
                                msg: "Removed friend",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                              );
                              //Navigator.pop(context);
                            } else if (isInIncomingRequests) {
                              await DatabaseService(uid: user.uid)
                                  .acceptRequest(uid);
                              Fluttertoast.showToast(
                                msg: "Added friend",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                              );
                              //Navigator.pop(context);
                            } else if (isInOutgoingRequests) {
                              await DatabaseService(uid: user.uid)
                                  .unSendRequest(uid);
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
                    SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: extraTileVISIBILITY,
                      child: ListTile(
                        leading: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green[300],
                              elevation: 10,
                              shadowColor: Colors.black),
                          child: Text(
                            "Accept",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          onPressed: () async {
                            // accept invite here
                            await DatabaseService(uid: user.uid)
                                .acceptRequest(uid);
                            Fluttertoast.showToast(
                              msg: "Friend added",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                            );
                            //Navigator.pop(context);
                          },
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red[300],
                              elevation: 10,
                              shadowColor: Colors.black),
                          child: Text(
                            "Reject",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          onPressed: () async {
                            // reject invite here
                            await DatabaseService(uid: user.uid)
                                .rejectRequest(uid);
                            Fluttertoast.showToast(
                              msg: "Request removed",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                            );
                            //Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
