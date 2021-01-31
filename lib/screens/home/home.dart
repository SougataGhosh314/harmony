import 'package:firebase_core/firebase_core.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/home/my_feed/posts.dart';
import 'package:harmony_ghosh/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context);

    return RefreshIndicator(
      onRefresh: () async {
        Navigator.pushNamed(context, "/home");
      },
      child: StreamBuilder<AppUser>(
          stream: DatabaseService(uid: user.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //setState(() {});
              AppUser appUser = snapshot.data;

              print("length of friends[] in Home(): " +
                  appUser.friends.length.toString());

              return Scaffold(
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        child: Text(
                          'Menu',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.white),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                        ),
                      ),
                      ListTile(
                        title: Text('My Timeline'),
                        onTap: () {
                          // Update the state of the app.
                          // ...
                          //Navigator.pop(context);
                          Navigator.popAndPushNamed(context, "/my_posts");
                        },
                      ),
                      ListTile(
                        title: Text('My lobby'),
                        onTap: () {
                          // Update the state of the app.
                          // ...
                          //Navigator.pop(context);
                          Navigator.popAndPushNamed(context, "/friends");
                        },
                      ),
                      ListTile(
                        title: Text('Sent Invites'),
                        onTap: () {
                          // Update the state of the app.
                          // ...
                          //Navigator.pop(context);
                          Navigator.popAndPushNamed(context, "/sent_requests");
                        },
                      ),
                      ListTile(
                        title: Text('Recieved Invites'),
                        onTap: () {
                          // Update the state of the app.
                          // ...
                          //Navigator.pop(context);
                          Navigator.popAndPushNamed(
                              context, "/recieved_requests");
                        },
                      ),
                      ListTile(
                        title: Text('People'),
                        onTap: () {
                          // Update the state of the app.
                          // ...
                          //Navigator.pop(context);
                          Navigator.popAndPushNamed(context, "/people");
                        },
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.white54,
                appBar: AppBar(
                  title: Text(
                    "${appUser.name}", // $emailOfSignedInUser
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: Colors.black87,
                  elevation: 0.0,
                  actions: [
                    FlatButton.icon(
                      icon: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, "/my_profile");
                      },
                      label: Text(
                        "Settings",
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    FlatButton.icon(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        //await _auth.signOut();
                        AuthService().signOut();
                      },
                      label: Text(
                        "logout",
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      Center(
                        child: ElevatedButton(
                          child: Text(
                            "Add Post",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            // add post here
                            Navigator.pushNamed(context, "/add_post");
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blue[100],
                              elevation: 10,
                              shadowColor: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: Posts(friends: appUser.friends),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              print(snapshot.toString());
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Loading(),
              );
            }
          }),
    );
  }
}
