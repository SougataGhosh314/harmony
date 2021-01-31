import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/screens/home/my_feed/post_list.dart';
import 'package:harmony_ghosh/screens/nav_items/my_timeline/my_post_list.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class MyPosts extends StatefulWidget {
  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context);

    return StreamBuilder<Object>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            AppUser appUser = snapshot.data;
            print("length of posts in MyPosts(): " +
                appUser.posts.length.toString());
            appUser.posts.forEach(
                (item) => print("friend from MyPosts stream::: " + item));
            return FutureProvider<List<FeedPost>>.value(
              value:
                  DatabaseService(uid: user.uid).getMyOwnPosts(appUser.posts),
              // update above to listen to posts future
              child: Scaffold(
                  appBar: AppBar(
                    title: Text("My timeline"),
                  ),
                  body: MyPostList()),
            );
          } else {
            return Loading();
          }
        });
  }
}
