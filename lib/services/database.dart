import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmony_ghosh/models/app_user.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference reference =
      FirebaseFirestore.instance.collection("appusers");

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

  //user data from snapshot
  AppUser _userDataFromSnapshot(DocumentSnapshot snapshot) {
    print(snapshot.get("phoneNumber"));
    // print(snapshot.get("profileImageUrl"));
    // // print(snapshot.get("friends"));

    // print("before invoking constructor");

    // print("checking snapshot: " +
    //     (snapshot.get("friends") is List<dynamic>).toString());

    // print(friends.toString() + " type: " + friends.runtimeType.toString());

    // AppUser x = AppUser(
    //     name: "dick",
    //     uid: "adwd",
    //     phoneNumber: "54450",
    //     friends: ["pen", "pencil"],
    //     posts: [],
    //     incomingRequests: [],
    //     outgoingRequests: [],
    //     profileImageUrl: "cdsc");

    // print("check object: " + (x.friends is List<String>).toString());

    AppUser user = AppUser(
        uid: uid,
        name: snapshot.get("name"),
        profileImageUrl: snapshot.get("profileImageUrl"),
        phoneNumber: snapshot.get("phoneNumber"),
        friends: dynamicListToStringList(snapshot.get("friends")),
        incomingRequests:
            dynamicListToStringList(snapshot.get("incomingRequests")),
        outgoingRequests:
            dynamicListToStringList(snapshot.get("outgoingRequests")),
        posts: dynamicListToStringList(snapshot.get("posts")));

    // print("after invoking constructor");

    // print("friends: ${user.friends}");

    return user;
  }

  // get user doc stream
  Stream<AppUser> get userData {
    return reference.doc(uid).snapshots().map(_userDataFromSnapshot);
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

    // print("reaches here");

    // await reference.doc(uid).get().then((DocumentSnapshot ds) {
    //   List<String> reqs = ds.data()["outgoingRequests"];
    //   reqs.add(id);
    //   reference
    //       .doc(uid)
    //       .set({"outgoingRequests": reqs})
    //       .then((val) => print("request sent"))
    //       .catchError((error) => print(error));
    // });
  }
}
