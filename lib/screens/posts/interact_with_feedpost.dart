import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/comment.dart';
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/screens/home/my_feed/post_tile.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:harmony_ghosh/screens/posts/interactiion_post_tile.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/constants.dart';
import 'package:provider/provider.dart';

class InteractWithFeedPost extends StatefulWidget {
  @override
  _InteractWithFeedPostState createState() => _InteractWithFeedPostState();
}

class _InteractWithFeedPostState extends State<InteractWithFeedPost> {
  Map data = {};
  String myComment = "";

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      data = ModalRoute.of(context).settings.arguments;
    } else {
      Map newData = ModalRoute.of(context).settings.arguments;
      if (newData.isNotEmpty) {
        data = newData;
      } else {
        data = data;
      }
    }
    //data = data.isNotEmpty ? data : ModalRoute.of(context).settings.arguments;

    FeedPost post = data["post"];
    //print(data["post"].creatorName);
    final user = Provider.of<AppUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Post from your feed"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              InteractionPostTile(
                post: post,
              ),
              SizedBox(
                height: 5,
              ),
              Text("Comments: "),
              FutureProvider<List<Comment>>.value(
                value: DatabaseService(uid: user.uid).getComments(post.postId),
                child: CommentList(),
              ),
              SizedBox(
                height: 5,
              ),
              Form(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
                        width: 280,
                        child: TextFormField(
                          initialValue: "",
                          keyboardType: TextInputType.multiline,
                          decoration: textInputDecoration.copyWith(
                              hintText: "Your comment"),
                          onChanged: (val) {
                            setState(() {
                              myComment = val;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        child: Text("Comment"),
                        onPressed: () async {
                          if (myComment != "") {
                            await DatabaseService(uid: user.uid)
                                .postComment(myComment, post.postId);

                            Fluttertoast.showToast(
                                msg: "Comment added",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER);

                            Navigator.pushNamed(
                                context, "/interact_with_feed_post",
                                arguments: {
                                  "post": await DatabaseService(uid: user.uid)
                                      .getUpdatedPost(post.postId)
                                });
                          } else {
                            Fluttertoast.showToast(
                                msg: "can't leave empty",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER);
                          }
                        },
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
  }
}

class CommentList extends StatefulWidget {
  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  @override
  Widget build(BuildContext context) {
    List<Comment> comments = Provider.of<List<Comment>>(context) ?? [];

    print("length of comments[] in comment_list widget: " +
        comments.length.toString());

    if (comments.length == 0) {
      print(true);
    }

    if (comments.length == 0) {
      return Text("No one has commented yet");
    } else {
      return Container(
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return CommentTile(comment: comments[index]);
          },
        ),
      );
    }
  }
}

class CommentTile extends StatefulWidget {
  final Comment comment;
  CommentTile({this.comment});

  @override
  _CommentTileState createState() => _CommentTileState(comment: comment);
}

class _CommentTileState extends State<CommentTile> {
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

  final Comment comment;
  _CommentTileState({this.comment});

  @override
  Widget build(BuildContext context) {
    String imageURL =
        "https://cdn.pixabay.com/photo/2013/08/26/11/04/quill-175980_960_720.png";

    if (profilePicFromDB == "") {
      getDownloadURL(comment.commenterId);
    }

    if (profilePicFromDB != "") {
      imageURL = profilePicFromDB;
    }

    return Card(
      elevation: 5,
      color: Colors.blue[100],
      margin: EdgeInsets.fromLTRB(10, 6, 10, 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageURL),
          radius: 25,
          backgroundColor: Colors.red,
        ),
        title: Text(
          comment.textContent,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        subtitle: Text(
          comment.timeStamp,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green, fontSize: 10),
        ),
        trailing: Icon(Icons.menu),
      ),
    );
  }
}
