import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/screens/home/my_feed/post_list.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class Posts extends StatefulWidget {
  final List<String> friends;
  AppUser user;
  Posts({this.friends, this.user});

  @override
  _PostsState createState() => _PostsState(friends: friends, user: user);
}

class _PostsState extends State<Posts> {
  final List<String> friends;
  AppUser user;
  _PostsState({this.friends, this.user});

  @override
  Widget build(BuildContext context) {
    final userX = Provider.of<AppUser>(context);

    print("length of friends in Posts(): " + friends.length.toString());
    friends.forEach((item) => print("friend from home stream::: " + item));

    return FutureProvider<List<FeedPost>>.value(
      value: DatabaseService(uid: userX.uid).getPosts(friends),
      // update above to listen to posts future
      child: PostList(user: user),
    );
  }
}
