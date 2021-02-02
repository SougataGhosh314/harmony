import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class PostTile extends StatefulWidget {
  FeedPost post;
  AppUser user;

  PostTile({this.post, this.user});

  @override
  _PostTileState createState() => _PostTileState(post: post, user: user);
}

class _PostTileState extends State<PostTile> {
  FeedPost post;
  AppUser user;
  _PostTileState({this.post, this.user});

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

  String postPicFromDB = "";

  bool isLikedByMe = false;
  String reactButtonText = "like";
  String reactInfoText = "";

  @override
  Widget build(BuildContext context) {
    final userX = Provider.of<AppUser>(context);

    String imageURL =
        "https://cdn.pixabay.com/photo/2013/08/26/11/04/quill-175980_960_720.png";

    if (profilePicFromDB == "") {
      getDownloadURL(post.postId.split("_")[0]);
    }

    if (profilePicFromDB != "") {
      imageURL = profilePicFromDB;
    }

    print(post.postId);
    print("post likes upon building: " + post.likes.length.toString());

    if (post.likes.length > 0) {
      setState(() {
        reactInfoText = post.likes.length.toString() + " people like this post";
      });
    }

    if (post.likes.contains(userX.uid)) {
      setState(() {
        reactInfoText = "You and " +
            (post.likes.length - 1).toString() +
            " others liked this post";
        if (post.likes.length == 1) {
          reactInfoText = "You liked this post";
        }
        isLikedByMe = true;
        reactButtonText = "unlike";
      });
    } else {
      setState(() {
        isLikedByMe = false;
        reactButtonText = "like";
      });
    }

    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Card(
        margin: EdgeInsets.fromLTRB(10, 6, 10, 0),
        child: Column(
          children: [
            Image(
              height: 200,
              width: 380,
              image: NetworkImage(post.mediaContentURL),
              fit: BoxFit.fill,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              post.textContent,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(imageURL),
                    radius: 18,
                    backgroundColor: Colors.red,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                        "by " + post.creatorName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue[700]),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text("on " + post.timeOfPost),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: ListTile(
                leading: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 10,
                      primary: Colors.blue[800],
                      shadowColor: Colors.blue),
                  child: Text(
                    reactButtonText,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (!isLikedByMe) {
                      await DatabaseService(uid: user.uid)
                          .reactToPost(post.postId, "like", true);
                      Fluttertoast.showToast(
                          msg: "liked",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER);

                      post.likes.add(user.uid);

                      print(post.postId);
                      print("post likes upon liking: " +
                          post.likes.length.toString());

                      setState(() {
                        if (post.likes.length == 1) {
                          reactInfoText = "You liked this post";
                          reactButtonText = "unlike";
                          isLikedByMe = true;
                        } else {
                          reactInfoText = "You and " +
                              (post.likes.length - 1).toString() +
                              " others liked this post";
                          reactButtonText = "unlike";
                          isLikedByMe = true;
                        }
                      });
                    } else {
                      await DatabaseService(uid: user.uid)
                          .reactToPost(post.postId, "like", false);
                      Fluttertoast.showToast(
                          msg: "unliked",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER);

                      post.likes.remove(user.uid);

                      print(post.postId);
                      print("post likes upon unliking: " +
                          post.likes.length.toString());

                      setState(() {
                        if (post.likes.length == 0) {
                          reactInfoText = "";
                          reactButtonText = "like";
                          isLikedByMe = false;
                        } else {
                          if (post.likes.length > 0) {
                            reactInfoText = post.likes.length.toString() +
                                " people like this post";
                          }
                          reactButtonText = "like";
                          isLikedByMe = false;
                        }
                      });
                    }
                  },
                ),
                subtitle: Text(
                  reactInfoText,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600]),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 10,
                      primary: Colors.brown[800],
                      shadowColor: Colors.amber),
                  child: Text(
                    "Comment",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    // redirect here
                    Navigator.pushNamed(context, "/interact_with_feed_post",
                        arguments: {"post": post});
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
