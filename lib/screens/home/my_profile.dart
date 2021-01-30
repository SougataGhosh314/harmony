import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/constants.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  // Future getUrl(StorageReference ref) async {
  //   return (await ref.getDownloadURL()).toString();
  // }

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

  String newName = "";
  bool VISISBILITY = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context);

    return StreamBuilder<AppUser>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            AppUser userData = snapshot.data;
            String imageURL = userData.profileImageUrl;
            if (profilePicFromDB == "") {
              getDownloadURL(userData.uid);
            }

            if (profilePicFromDB != "") {
              imageURL = profilePicFromDB;
              print(imageURL);
            }
            //print("After function call: $imageURL");
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "My Profile",
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Colors.black45,
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: FlatButton(
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(imageURL),
                            //AssetImage("assets/batman.jpg"),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, "/image_picker");
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              userData.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            SizedBox(
                              height: 0,
                            ),
                            //Text("UID: ${userData.uid}"),
                            SizedBox(
                              height: 20,
                            ),
                            Text(userData.phoneNumber),
                            SizedBox(
                              height: 20,
                            ),
                            FlatButton(
                              child: Text("Change name"),
                              color: Colors.green,
                              onPressed: () {
                                setState(() {
                                  VISISBILITY = true;
                                });
                              },
                            ),
                            Visibility(
                              visible: VISISBILITY,
                              child: Form(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      initialValue: userData.name,
                                      keyboardType: TextInputType.name,
                                      decoration: textInputDecoration.copyWith(
                                          hintText: "new name"),
                                      onChanged: (val) {
                                        setState(() => {newName = val});
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    FlatButton(
                                      child: Text("Update name"),
                                      onPressed: () async {
                                        await DatabaseService(uid: userData.uid)
                                            .updateName(newName);
                                        Fluttertoast.showToast(
                                          msg: "Name updated",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                        );
                                        VISISBILITY = false;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
