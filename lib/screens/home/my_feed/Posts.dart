import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/screens/home/my_feed/post_list.dart';
import 'package:harmony_ghosh/screens/nav_items/friends/friend_list.dart';
import 'package:harmony_ghosh/screens/nav_items/friends/friend_tile.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context);

    return FutureProvider<List<FeedPost>>.value(
      value: DatabaseService(uid: user.uid).getPosts(),
      // update above to listen to posts future
      child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: PostList()),
    );
  }
}
