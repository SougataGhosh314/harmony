import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/screens/home/my_feed/post_tile.dart';
import 'package:harmony_ghosh/screens/nav_items/friends/friend_tile.dart';
import 'package:harmony_ghosh/screens/nav_items/my_timeline/my_post_tile.dart';
import 'package:provider/provider.dart';

class MyPostList extends StatefulWidget {
  @override
  _MyPostListState createState() => _MyPostListState();
}

class _MyPostListState extends State<MyPostList> {
  @override
  Widget build(BuildContext context) {
    var posts = Provider.of<List<FeedPost>>(context) ?? [];
    // update above and below
    print("length of posts[] in post_list widget: " + posts.length.toString());
    return ListView.builder(
      shrinkWrap: true,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return MyPostTile(post: posts[index]);
      },
    );
  }
}
