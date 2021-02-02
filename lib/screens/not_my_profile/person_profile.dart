import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/screens/home/my_feed/post_tile.dart';
import 'package:harmony_ghosh/screens/nav_items/people/person_tile.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/constants.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonProfile extends StatefulWidget {
  @override
  _PersonProfileState createState() => _PersonProfileState();
}

class _PersonProfileState extends State<PersonProfile> {
  Map data = {};
  AppUser me;
  String personId;

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context).settings.arguments;
    me = data["me"];
    personId = data["personId"];

    //final user = Provider.of<AppUser>(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Person", //+ Provider.of<AppUser>(context).name,
        style: TextStyle(fontSize: 12, color: Colors.white),
      )),
      body: Container(
          child: FutureProvider<Map>.value(
        value: DatabaseService(uid: me.uid)
                .getPersonAndPublicPosts(me, personId) ??
            {},
        child: Column(children: [
          Expanded(flex: 2, child: PersonInfo(uidOfPerson: personId)),
          Expanded(flex: 3, child: PublicPosts(me: me))
        ]),
      )),
    );
  }
}

class PersonInfo extends StatefulWidget {
  String uidOfPerson;
  PersonInfo({this.uidOfPerson});
  @override
  _PersonInfoState createState() => _PersonInfoState(uidOfPerson: uidOfPerson);
}

class _PersonInfoState extends State<PersonInfo> {
  String uidOfPerson;
  _PersonInfoState({this.uidOfPerson});
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

    return url;
  }

  @override
  Widget build(BuildContext context) {
    AnotherUser person = Provider.of<Map>(context) != null
        ? Provider.of<Map>(context)["person"]
        : AnotherUser(
            name: "name",
            uid: "",
            profileImageUrl:
                "https://cdn.pixabay.com/photo/2013/08/26/11/04/quill-175980_960_720.png",
            bio: "",
            mutualFriendIds: [], // actually sends back mutual friends, not friends
            mutualFriendNames: [],
            publicPosts: []);

    //print("23a:: " + person.name);

    String imageURL = person.profileImageUrl;
    if (profilePicFromDB == "") {
      getDownloadURL(uidOfPerson);
    }

    if (profilePicFromDB != "") {
      imageURL = profilePicFromDB;
      print(imageURL);
    }

    return Center(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageURL),
                //AssetImage("assets/batman.jpg"),
              ),
            ),
            Column(
              children: [
                Text(
                  person.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 24),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  person.bio,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          "Mutual friends",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 24),
        ),
        SizedBox(
          height: 15,
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: person.mutualFriendNames.length,
            itemBuilder: (context, index) {
              return PersonTile(
                  uid: person.mutualFriendIds[index],
                  name: person.mutualFriendNames[index]);
            },
          ),
        ),
      ],
    ));
  }
}

class PublicPosts extends StatefulWidget {
  AppUser me;
  PublicPosts({this.me});

  @override
  _PublicPostsState createState() => _PublicPostsState(me: me);
}

class _PublicPostsState extends State<PublicPosts> {
  AppUser me;
  _PublicPostsState({this.me});

  @override
  Widget build(BuildContext context) {
    List<FeedPost> posts = Provider.of<Map>(context) != null
        ? Provider.of<Map>(context)["posts"]
        : [];

    return Center(
        child: Column(
      children: [
        Text(
          "Public posts: ",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 24),
        ),
        SizedBox(
          height: 15,
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostTile(post: posts[index], user: me);
            },
          ),
        ),
      ],
    ));
  }
}
