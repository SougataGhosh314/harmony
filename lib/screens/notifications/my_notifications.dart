import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/my_notification.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:provider/provider.dart';

class MyNotifications extends StatefulWidget {

  @override
  _MyNotificationsState createState() => _MyNotificationsState();
}

class _MyNotificationsState extends State<MyNotifications> {
  Map data = {};
  AppUser me;

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context).settings.arguments;
    me = data["me"];

    final user = Provider.of<AppUser>(context);
    return FutureProvider<List<MyNotification>>.value(
        value: DatabaseService(uid: user.uid).getMyNotifications(),
        child: Scaffold(
          appBar: AppBar(
            title: Text("My notifications"),
          ),
          body: NotificationList(me: me),
        ),
    );
  }
}

class NotificationList extends StatefulWidget {
  AppUser me;
  NotificationList({this.me});

  @override
  _NotificationListState createState() => _NotificationListState(me: me);
}

class _NotificationListState extends State<NotificationList> {
  AppUser me;
  _NotificationListState({this.me});

  @override
  Widget build(BuildContext context) {
    List<MyNotification> list = Provider.of<List<MyNotification>>(context) ?? [];

    Iterable inReverse = list.reversed;
    list = inReverse.toList();

    return ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return NotificationTile(me: me, notification: list[index]);
        }
    );
  }
}

class NotificationTile extends StatefulWidget {
  MyNotification notification;
  AppUser me;
  NotificationTile({this.notification, this.me});

  @override
  _NotificationTileState createState() => _NotificationTileState(me: me, notification: notification);
}

class _NotificationTileState extends State<NotificationTile> {
  MyNotification notification;
  AppUser me;
  _NotificationTileState({this.notification, this.me});
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

  Future getFeedPost(String postId) async {
    CollectionReference ref = FirebaseFirestore.instance.collection("posts");
    FeedPost post;
    post = FeedPost(
        postId: "",
        timeOfPost: "",
        creatorName: "post was deleted",
        likes: [],
        comments: [],
        mediaContentURL: "",
        textContent: ""
    );
    await ref.doc(postId).get().then(
        (ds) async {
          if(ds.exists) {
            String timeStamp = ds.get("postId").split("_")[1];

            post = FeedPost(
                postId: ds.get("postId"),
                timeOfPost: DateTime.fromMillisecondsSinceEpoch(
                    int.parse(timeStamp))
                    .toString(),
                creatorName: await DatabaseService(uid: me.uid).getNameFromDB(
                    ds.get("creatorId")),
                likes: DatabaseService(uid: me.uid).dynamicListToStringList(
                    ds.get("likes")),
                comments: DatabaseService(uid: me.uid).dynamicListToStringList(
                    ds.get("comments")),
                mediaContentURL: ds.get("mediaContentURL"),
                textContent: ds.get("textContent")
            );
          }
        }
    );
    return post;
  }

  @override
  Widget build(BuildContext context) {

    String imageURL =
        "https://cdn.pixabay.com/photo/2013/08/26/11/04/quill-175980_960_720.png";

    if (profilePicFromDB == "") {
      getDownloadURL(notification.fromWhomId);
    }

    if (profilePicFromDB != "") {
      imageURL = profilePicFromDB;
    }

    String titleText;
    String buttonFunction = "";
    if(notification.type == "0" || notification.type == "0"){
      buttonFunction = "goToPersonProfile";
    } else {
      buttonFunction = "goToPost";
    }

    switch (notification.type) {
      case "0": {
        titleText = notification.fromWhomName + " sent you a friend request.";
      }
      break;
      case "1": {
        titleText = notification.fromWhomName + " has accepted your friend request.";
      }
      break;
      case "2": {
        titleText = notification.fromWhomName + " likes your post.";
      }
      break;
      case "3": {
        titleText = notification.fromWhomName + " commented on your post.";
      }
      break;
      case "4": {
        titleText = notification.fromWhomName + " added a post.";
      }
      break;
      default: { print("cant get type"); }
      break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageURL),
        radius: 25,
        backgroundColor: Colors.red,
      ),
      title: Text(titleText),
      subtitle: Text(
          notification.timeStamp
      ),
      trailing: FloatingActionButton(
        heroTag: null,
        child: Icon(
          Icons.read_more
        ),
        onPressed: () async {
          if (buttonFunction == "goToPersonProfile") {
            Navigator.pushNamed(context, "/person_profile", arguments: {
              "me": me,
              "personId": notification.fromWhomId
            });
          } else if (buttonFunction == "goToPost") {
            FeedPost post = await getFeedPost(notification.postId);
            Navigator.pushNamed(context, "/interact_with_feed_post", arguments: {
              "post": post
            });
          }
        },
      ),
    );
  }
}

