import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/chat_thread.dart';
import 'package:harmony_ghosh/models/comment.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:harmony_ghosh/models/my_notification.dart';
import 'package:harmony_ghosh/models/post.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference reference =
      FirebaseFirestore.instance.collection("appusers");

  // collection reference
  final CollectionReference notiReference =
      FirebaseFirestore.instance.collection("notifications");

  // collection reference
  final CollectionReference chatThreadsReference =
      FirebaseFirestore.instance.collection("chatthreads");

  final CollectionReference postReference =
      FirebaseFirestore.instance.collection("posts");

  Future updateName(String newName) {
    reference.doc(uid).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        reference.doc(uid).update({"name": newName});
        print("name updated");
        //print("Document reference: ${ds.data()}");
      } else {
        print("it should never reach here");
      }
    });
  }

  Future updateUserData() async {
    //reference.doc(uid).update
    reference.doc(uid).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        print("Document reference: ${ds.data()}");
      } else {
        String nameToSet = "not set";
        String imageURL =
            "https://cdn.pixabay.com/photo/2013/08/26/11/04/quill-175980_960_720.png";

        List<String> friends = [];
        List<String> incomingRequests = [];
        List<String> outgoingRequests = [];
        List<String> posts = [];
        List<String> notifications = [];
        String bio = "";

        reference.doc(uid).set({
          "name": nameToSet,
          "phoneNumber":
              FirebaseAuth.instance.currentUser.phoneNumber.toString(),
          "uid": uid,
          "profileImageUrl": imageURL,
          "friends": friends,
          "incomingRequests": incomingRequests,
          "outgoingRequests": outgoingRequests,
          "posts": posts,
          "bio": bio,
          "notifications": notifications
        });
      }
    });
  }

  // user list from snapshot
  List<AppUser> _userListFromSnapshot(QuerySnapshot snapshot) {
    List<AppUser> list = [];
    snapshot.docs.forEach((doc) {
      print("Person found: " + doc["name"].toString());
      list.add(AppUser(
          name: doc["name"],
          uid: doc["uid"],
          phoneNumber: "private",
          profileImageUrl: "private",
          bio: "",
          friends: [],
          notifications: [],
          incomingRequests: [],
          outgoingRequests: [],
          posts: []));
    });
    print("list at the end: " + list.toString());
    return list;
  }

  // get userStream (gets us an updated state of the databse)
  Stream<List<AppUser>> get users {
    //print("length:   " +
    //    reference.snapshots().map(_userListFromSnapshot).length.toString());
    return reference.snapshots().map(_userListFromSnapshot);
  }

  List<String> dynamicListToStringList(List<dynamic> list) {
    List<String> toReturn = [];

    list.forEach((item) {
      toReturn.add(item.toString());
    });

    return toReturn;
  }

  // get user doc stream
  Stream<AppUser> get userData {
    //AppUser appUser;
    return reference.doc(uid).snapshots().map((DocumentSnapshot ds) {
      print(ds.get("phoneNumber"));
      print(ds.get("friends").length);
      print("tag 34f: " + ds.get("bio"));
      AppUser appUser;

      appUser = AppUser(
          uid: uid,
          name: ds.get("name"),
          bio: ds.get("bio"),
          profileImageUrl: ds.get("profileImageUrl"),
          phoneNumber: ds.get("phoneNumber"),
          friends: dynamicListToStringList(ds.get("friends")),
          notifications: dynamicListToStringList(ds.get("notifications")),
          incomingRequests: dynamicListToStringList(ds.get("incomingRequests")),
          outgoingRequests: dynamicListToStringList(ds.get("outgoingRequests")),
          posts: dynamicListToStringList(ds.get("posts")));

      return appUser;
    });

    //return appUser;
    //return reference.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  Future getNameFromDB(String uid) async {
    String name = await reference.doc(uid).get().then((sp) {
      print("Found one: " + sp.data()["name"].toString());
      // friendName = sp.data()["name"].toString();
      // print(friendName);
      return sp.data()["name"].toString();
    });

    return name;
  }

  // friend list from snapshot
  Future<List<AppUser>> getFriends() async {
    List<AppUser> list = [];

    await reference.doc(uid).get().then((DocumentSnapshot ds) async {
      for (var i = 0; i < ds.data()["friends"].length; i++) {
        String friendName = await getNameFromDB(ds.data()["friends"][i]);
        print("point X: " + friendName + " :: " + ds.data()["friends"][i]);
        print(friendName.runtimeType);

        list.add(AppUser(
            name: friendName,
            uid: ds.data()["friends"][i],
            phoneNumber: "private",
            profileImageUrl: "private",
            bio: "",
            friends: [],
            notifications: [],
            incomingRequests: [],
            outgoingRequests: [],
            posts: []));

        print("point Y: state of list:" + list.toString());
      }
    });

    print("reached here");
    print("friend list at the end: " + list.toString());
    return list;
  }

  // get another person (could be friend, or not) // needs more work, maybe
  Future<Map> getPersonAndPublicPosts(AppUser me, String personId) async {
    print(me.name);
    print(personId);
    Map toReturn = {};

    AnotherUser person;
    List<FeedPost> posts = [];

    await reference.doc(personId).get().then((ds) async {
      List<String> mutualFriendIds = dynamicListToStringList(ds.get("friends"));
      mutualFriendIds.forEach((item) => print(item));
      mutualFriendIds.removeWhere((item) => !me.friends.contains(item));

      List<String> mutualFriendNames = [];
      for (int i = 0; i < mutualFriendIds.length; i++) {
        String temp = await getNameFromDB(mutualFriendIds[i]);
        mutualFriendNames.add(temp);
      }
      person = AnotherUser(
          name: ds.get("name"),
          uid: ds.get("uid"),
          profileImageUrl: ds.get("profileImageUrl"),
          bio: ds.get("bio"),
          mutualFriendIds:
              mutualFriendIds, // actually sends back mutual friends, not friends
          mutualFriendNames: mutualFriendNames,
          publicPosts: []);
    });
    print("person name: " + person.name);

    await reference.doc(personId).get().then((ds) async {
      if (ds.exists) {
        List<String> postsIds = dynamicListToStringList(ds.get("posts"));

        for (int i = 0; i < postsIds.length; i++) {
          await postReference.doc(postsIds[i]).get().then((sp) async {
            if (sp.get("visibility") == "public") {
              posts.add(FeedPost(
                  comments: dynamicListToStringList(sp.get("comments")),
                  creatorName: await getNameFromDB(sp.get("creatorId")),
                  mediaContentURL: sp.get("mediaContentURL"),
                  likes: dynamicListToStringList(sp.get("likes")),
                  textContent: sp.get("textContent"),
                  postId: sp.get("postId"),
                  timeOfPost: DateTime.fromMillisecondsSinceEpoch(
                          int.parse(sp.get("postId").split("_")[1]))
                      .toString()));
            }
          });
        }
      }
    });

    toReturn = {"person": person, "posts": posts};

    return toReturn;
  }

  // friend list from snapshot
  Future<List<AppUser>> getSentRequests() async {
    List<AppUser> list = [];

    await reference.doc(uid).get().then((DocumentSnapshot ds) async {
      for (var i = 0; i < ds.data()["outgoingRequests"].length; i++) {
        String friendName =
            await getNameFromDB(ds.data()["outgoingRequests"][i]);
        print("point X: " +
            friendName +
            " :: " +
            ds.data()["outgoingRequests"][i]);
        print(friendName.runtimeType);

        list.add(AppUser(
            name: friendName,
            uid: ds.data()["outgoingRequests"][i],
            phoneNumber: "private",
            profileImageUrl: "private",
            bio: "",
            friends: [],
            notifications: [],
            incomingRequests: [],
            outgoingRequests: [],
            posts: []));

        print("point Y: state of list:" + list.toString());
      }
    });

    print("reached here");
    print("friend list at the end: " + list.toString());
    return list;
  }

  // friend list from snapshot
  Future<List<AppUser>> getRecievedRequests() async {
    List<AppUser> list = [];

    await reference.doc(uid).get().then((DocumentSnapshot ds) async {
      for (var i = 0; i < ds.data()["incomingRequests"].length; i++) {
        String friendName =
            await getNameFromDB(ds.data()["incomingRequests"][i]);
        print("point X: " +
            friendName +
            " :: " +
            ds.data()["incomingRequests"][i]);
        print(friendName.runtimeType);

        list.add(AppUser(
            name: friendName,
            uid: ds.data()["incomingRequests"][i],
            phoneNumber: "private",
            profileImageUrl: "private",
            bio: "",
            friends: [],
            notifications: [],
            incomingRequests: [],
            outgoingRequests: [],
            posts: []));

        print("point Y: state of list:" + list.toString());
      }
    });

    print("reached here");
    print("friend list at the end: " + list.toString());
    return list;
  }

  // send friend request
  Future sendRequest(String id) async {
    print("reaches sendRequest: " + id + " : " + uid);

    reference.doc(id).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs =
            dynamicListToStringList(ds.data()["incomingRequests"]);
        reqs.forEach((item) => print(item));

        reqs.add(uid);
        reference.doc(id).update({"incomingRequests": reqs});
      }
    });

    reference.doc(uid).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs =
            dynamicListToStringList(ds.data()["outgoingRequests"]);
        reqs.forEach((item) => print(item));

        reqs.add(id);
        reference.doc(uid).update({"outgoingRequests": reqs});
      }
    });

    createNotification(
        MyNotification(
            type: "0",
            fromWhomId: uid,
            fromWhomName: await getNameFromDB(uid),
        timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: "",
        ownerId: id
    )
    );
  }

  // unsend friend request
  Future unSendRequest(String id) {
    print("reaches unSendRequest: " + id + " : " + uid);

    reference.doc(id).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs =
            dynamicListToStringList(ds.data()["incomingRequests"]);
        reqs.forEach((item) => print(item));

        reqs.remove(uid);
        reference.doc(id).update({"incomingRequests": reqs});
      }
    });

    reference.doc(uid).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs =
            dynamicListToStringList(ds.data()["outgoingRequests"]);
        reqs.forEach((item) => print(item));

        reqs.remove(id);
        reference.doc(uid).update({"outgoingRequests": reqs});
      }
    });
  }

  // accept friend request
  Future acceptRequest(String id)async {
    print("reaches acceptRequest: " + id + " : " + uid);

    // remove from my incoming list
    reference.doc(uid).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs =
            dynamicListToStringList(ds.data()["incomingRequests"]);
        reqs.forEach((item) => print(item));

        reqs.remove(id);
        reference.doc(uid).update({"incomingRequests": reqs});
      }
    });

    // remove from his outgoing list
    reference.doc(id).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs =
            dynamicListToStringList(ds.data()["outgoingRequests"]);
        reqs.forEach((item) => print(item));

        reqs.remove(uid);
        reference.doc(id).update({"outgoingRequests": reqs});
      }
    });

    // add it to my friend list
    reference.doc(uid).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs = dynamicListToStringList(ds.data()["friends"]);
        reqs.forEach((item) => print(item));

        reqs.add(id);
        reference.doc(uid).update({"friends": reqs});
      }
    });

    // add it to his/her friend list
    reference.doc(id).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs = dynamicListToStringList(ds.data()["friends"]);
        reqs.forEach((item) => print(item));

        reqs.add(uid);
        reference.doc(id).update({"friends": reqs});
      }
    });

    createNotification(
        MyNotification(
            type: "1",
            fromWhomId: uid,
            fromWhomName: await getNameFromDB(uid),
        timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: "",
        ownerId: id
    )
    );
  }

  // reject friend request
  Future rejectRequest(String id) {
    print("reaches rejectRequest: " + id + " : " + uid);

    reference.doc(uid).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs =
            dynamicListToStringList(ds.data()["incomingRequests"]);
        reqs.forEach((item) => print(item));

        reqs.remove(id);
        reference.doc(uid).update({"incomingRequests": reqs});
      }
    });

    reference.doc(id).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs =
            dynamicListToStringList(ds.data()["outgoingRequests"]);
        reqs.forEach((item) => print(item));

        reqs.remove(uid);
        reference.doc(id).update({"outgoingRequests": reqs});
      }
    });
  }

  // unfriend
  Future unFriend(String id) {
    print("reaches unFriend: " + id + " : " + uid);

    reference.doc(uid).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs = dynamicListToStringList(ds.data()["friends"]);
        reqs.forEach((item) => print(item));

        reqs.remove(id);
        reference.doc(uid).update({"friends": reqs});
      }
    });

    reference.doc(id).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs = dynamicListToStringList(ds.data()["friends"]);
        reqs.forEach((item) => print(item));

        reqs.remove(uid);
        reference.doc(id).update({"friends": reqs});
      }
    });
  }

  // create post
  Future createPost(Post post) async {
    postReference.doc(post.postId).set({
      "postId": post.postId,
      "creatorId": post.creatorId,
      "textContent": post.textContent,
      "mediaContentURL": post.mediaContentURL,
      "visibility": post.visibility,
      "comments": [],
      "likes": []
    });

    reference.doc(uid).get().then((DocumentSnapshot ds) {
      List<String> posts = dynamicListToStringList(ds.data()["posts"]);
      posts.add(post.postId);
      reference.doc(uid).update({"posts": posts});
    });

    reference.doc(uid).get().then(
        (ds) async {
          List<String> friends = dynamicListToStringList(ds.get("friends"));
          for(int i=0; i<friends.length; i++) {
            createNotification(
                MyNotification(
                    type: "4",
                    fromWhomId: uid,
                    fromWhomName: await getNameFromDB(uid),
                timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
                postId: post.postId,
                ownerId: friends[i]
            )
          );
          }
        }
    );
  }

  // delete post
  Future deletePost(String postId) async {
    postReference.doc(postId).delete();

    reference.doc(uid).get().then((DocumentSnapshot ds) {
      List<String> posts = dynamicListToStringList(ds.data()["posts"]);
      posts.remove(postId);
      reference.doc(uid).update({"posts": posts});
    });

    firebase_storage.FirebaseStorage.instance.ref()
        .child("post_media/" + postId + ".png")
        .delete();
  }

  // post list from snapshot
  Future<List<FeedPost>> getPosts(List<String> friends) async {
    List<FeedPost> list = [];

    for (var i = 0; i < friends.length; i++) {
      await reference.doc(friends[i]).get().then((DocumentSnapshot sp) async {
        for (var i = 0; i < sp.data()["posts"].length; i++) {
          await postReference
              .doc(sp.data()["posts"][i])
              .get()
              .then((DocumentSnapshot postDoc) async {
            if (postDoc.data()["visibility"] != "private") {
              String timeStamp = postDoc.data()["postId"].split("_")[1];

              list.add(FeedPost(
                  postId: postDoc.data()["postId"],
                  creatorName: await getNameFromDB(postDoc.data()["creatorId"]),
                  textContent: postDoc.data()["textContent"],
                  mediaContentURL: postDoc.data()["mediaContentURL"],
                  timeOfPost:
                      DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp))
                          .toString(),
                  comments: dynamicListToStringList(postDoc.data()["comments"]),
                  likes: dynamicListToStringList(postDoc.data()["likes"])));
            }
          });
        }
      });
    }

    print("reached here");
    print("post list at the end: " + list.toString());
    return list;
  }

  Future<List<FeedPost>> getMyOwnPosts(List<String> posts) async {
    List<FeedPost> list = [];
    for (var i = 0; i < posts.length; i++) {
      await postReference
          .doc(posts[i])
          .get()
          .then((DocumentSnapshot postDoc) async {
        String timeStamp = postDoc.data()["postId"].split("_")[1];

        list.add(FeedPost(
            postId: postDoc.data()["postId"],
            creatorName: await getNameFromDB(postDoc.data()["creatorId"]),
            textContent: postDoc.data()["textContent"],
            mediaContentURL: postDoc.data()["mediaContentURL"],
            timeOfPost:
                DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp))
                    .toString(),
            comments: dynamicListToStringList(postDoc.data()["comments"]),
            likes: dynamicListToStringList(postDoc.data()["likes"])));
      });
    }

    print("reached here");
    print("post list at the end: " + list.toString());
    return list;
  }

  Future<List<Comment>> getComments(String postId) async {
    List<Comment> comments = [];
    await postReference
        .doc(postId)
        .get()
        .then((DocumentSnapshot postDoc) async {
      if (postDoc.data()["comments"].length != 0) {
        print(postDoc.data()["comments"].length.toString() +
            postDoc.data()["comments"][0]);

        for (int i = 0; i < postDoc.data()["comments"].length; i++) {
          String timeStamp = postDoc.data()["comments"][i].split("_")[1];
          String id = postDoc.data()["comments"][i].split("_")[0];
          String text = postDoc.data()["comments"][i].split("_")[2];

          comments.add(Comment(
            commenterId: id,
            commenter: await getNameFromDB(id),
            timeStamp: DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp))
                .toString(),
            textContent: text,
          ));
        }
      }
    });

    print("reached here");
    print("comments list at the end: " + comments.toString());
    return comments;
  }

  // post a comment
  Future postComment(String text, String postId) async {
    print("reaches postComment: " + text + " : " + uid);

    postReference.doc(postId).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        List<String> reqs = dynamicListToStringList(ds.data()["comments"]);
        reqs.forEach((item) => print(item));

        String comment = uid.toString() +
            "_" +
            DateTime.now().millisecondsSinceEpoch.toString() +
            "_" +
            text;

        reqs.add(comment);
        postReference.doc(postId).update({"comments": reqs});
      }
    });

    createNotification(
        MyNotification(
            type: "3",
            fromWhomId: uid,
            fromWhomName: await getNameFromDB(uid),
        timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: postId,
        ownerId: postId.split("_")[0]
    )
    );
  }

  Future getUpdatedPost(String postId) async {
    FeedPost updatedPost;

    await postReference.doc(postId).get().then((DocumentSnapshot ds) async {
      if (ds.exists) {
        String timeStamp = ds.data()["postId"].split("_")[1];

        updatedPost = FeedPost(
            postId: ds.data()["postId"],
            creatorName: await getNameFromDB(ds.data()["creatorId"]),
            textContent: ds.data()["textContent"],
            mediaContentURL: ds.data()["mediaContentURL"],
            timeOfPost:
                DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp))
                    .toString(),
            comments: dynamicListToStringList(ds.data()["comments"]),
            likes: dynamicListToStringList(ds.data()["likes"]));
      }
    });

    return updatedPost;
  }

  Future sendMessage(String recipientId, String message) async {
    bool done = false;

    String modifiedMessage = uid +
        "_" +
        recipientId +
        "_" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        "_" +
        message;

    await chatThreadsReference
        .doc(uid + "_" + recipientId)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.exists) {
        print("Existence::: " + "uid_recipientId");

        List<String> reqs = dynamicListToStringList(ds.data()["chatList"]);
        reqs.forEach((item) => print(item));

        reqs.add(modifiedMessage);
        chatThreadsReference
            .doc(uid + "_" + recipientId)
            .update({"chatList": reqs});
        done = true;
      }
    });

    if (!done) {
      await chatThreadsReference
          .doc(recipientId + "_" + uid)
          .get()
          .then((DocumentSnapshot ds) {
        if (ds.exists) {
          print("Existence::: " + "uid_recipientId");
          List<String> reqs = dynamicListToStringList(ds.data()["chatList"]);
          reqs.forEach((item) => print(item));

          reqs.add(modifiedMessage);
          chatThreadsReference
              .doc(recipientId + "_" + uid)
              .update({"chatList": reqs});
          done = true;
        }
      });
    }

    if (!done) {
      await chatThreadsReference.doc(uid + "_" + recipientId).set({
        "participantOne": uid,
        "participantTwo": recipientId,
        "chatList": [modifiedMessage]
      });
    }
  }

  Future reactToPost(String postId, String reactionType, bool action) async {
    if (reactionType == "like" && action == true) {
      // liking
      postReference.doc(postId).get().then((ds) {
        List<String> likes = dynamicListToStringList(ds.get("likes"));
        likes.add(uid);
        postReference.doc(postId).update({"likes": likes});
      });

      createNotification(
        MyNotification(
          type: "2",
          fromWhomId: uid,
          fromWhomName: await getNameFromDB(uid),
          timeStamp: DateTime.now().millisecondsSinceEpoch.toString(),
          postId: postId,
          ownerId: postId.split("_")[0]
        )
      );

    } else if (reactionType == "like" && action == false) {
      // unliking
      postReference.doc(postId).get().then((ds) {
        List<String> likes = dynamicListToStringList(ds.get("likes"));
        likes.remove(uid);
        postReference.doc(postId).update({"likes": likes});
      });
    }
  }

  // create a notification in the db for uid
  Future createNotification(MyNotification notification) async {
    await notiReference
        .doc(notification.ownerId + "_" +
        notification.timeStamp)
        .set({
      "ownerId": notification.ownerId,
      "type": notification.type,
      "timeStamp": notification.timeStamp,
      "fromWhomId": notification.fromWhomId,
      "fromWhomName": notification.fromWhomName,
      "postId": notification.postId
    });

    await reference.doc(notification.ownerId).get().then((ds) {
      if (ds.exists) {
        List<String> notifications =
            dynamicListToStringList(ds.get("notifications"));
        notifications.add(notification.ownerId + "_" +
            notification.timeStamp);
        reference.doc(notification.ownerId).update({"notifications": notifications});
      }
    });
  }

  // get my notifications
  Future<List<MyNotification>> getMyNotifications() async {
    List<MyNotification> list = [];
    await reference.doc(uid).get().then((ds) async {
      if (ds.exists) {
        List<String> notifications =
            dynamicListToStringList(ds.get("notifications"));

        for (int i = 0; i < notifications.length; i++) {
          await notiReference.doc(notifications[i]).get().then((sp) {
            if (sp.exists) {
              list.add(
                MyNotification(
                  ownerId: sp.get("ownerId"),
                  fromWhomId: sp.get("fromWhomId"),
                  fromWhomName: sp.get("fromWhomName"),
                  timeStamp: DateTime
                      .fromMillisecondsSinceEpoch(int.parse(sp.get("timeStamp")))
                      .toString(),
                  postId: sp.get("postId"),
                  type: sp.get("type"),
                )
              );
            }
          });
        }
      }
    });

    return list;
  }


}
