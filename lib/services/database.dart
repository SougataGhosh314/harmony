import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/post.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference reference =
      FirebaseFirestore.instance.collection("appusers");

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

        reference.doc(uid).set({
          "name": nameToSet,
          "phoneNumber":
              FirebaseAuth.instance.currentUser.phoneNumber.toString(),
          "uid": uid,
          "profileImageUrl": imageURL,
          "friends": friends,
          "incomingRequests": incomingRequests,
          "outgoingRequests": outgoingRequests,
          "posts": posts
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
          friends: [],
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

  // //user data from snapshot
  // AppUser _userDataFromSnapshot(DocumentSnapshot snapshot) {
  //   print(snapshot.get("phoneNumber"));
  //   AppUser user = AppUser(
  //       uid: uid,
  //       name: snapshot.get("name"),
  //       profileImageUrl: snapshot.get("profileImageUrl"),
  //       phoneNumber: snapshot.get("phoneNumber"),
  //       friends: dynamicListToStringList(snapshot.get("friends")),
  //       incomingRequests:
  //           dynamicListToStringList(snapshot.get("incomingRequests")),
  //       outgoingRequests:
  //           dynamicListToStringList(snapshot.get("outgoingRequests")),
  //       posts: dynamicListToStringList(snapshot.get("posts")));

  //   return user;
  // }

  // get user doc stream
  Stream<AppUser> get userData {
    //AppUser appUser;
    return reference.doc(uid).snapshots().map((DocumentSnapshot ds) {
      print(ds.get("phoneNumber"));
      print(ds.get("friends").length);
      AppUser appUser;

      appUser = AppUser(
          uid: uid,
          name: ds.get("name"),
          profileImageUrl: ds.get("profileImageUrl"),
          phoneNumber: ds.get("phoneNumber"),
          friends: dynamicListToStringList(ds.get("friends")),
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
            friends: [],
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
            friends: [],
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
            friends: [],
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
  Future sendRequest(String id) {
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
  Future acceptRequest(String id) {
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
  }

  // delete post
  Future deletePost(String postId) async {
    postReference.doc(postId).delete();

    reference.doc(uid).get().then((DocumentSnapshot ds) {
      List<String> posts = dynamicListToStringList(ds.data()["posts"]);
      posts.remove(postId);
      reference.doc(uid).update({"posts": posts});
    });
  }

  // post list from snapshot
  Future<List<FeedPost>> getPosts(List<String> friends) async {
    List<FeedPost> list = [];

    for (var i = 0; i < friends.length; i++) {
      await reference.doc(friends[i]).get().then((DocumentSnapshot sp) async {
        // print("31a post found for friend " +
        //     ds.data()["friends"][i] +
        //     " :: " +
        //     sp.data()["posts"].length.toString());

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
                  // (DateTime.fromMillisecondsSinceEpoch(
                  //         postDoc.data()["postId"].split("_")[1]))
                  //     .toString()
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
            // (DateTime.fromMillisecondsSinceEpoch(
            //         postDoc.data()["postId"].split("_")[1]))
            //     .toString()
            comments: dynamicListToStringList(postDoc.data()["comments"]),
            likes: dynamicListToStringList(postDoc.data()["likes"])));
      });
    }

    print("reached here");
    print("post list at the end: " + list.toString());
    return list;
  }
}
