import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/nav_items/friends/friend_tile.dart';
import 'package:provider/provider.dart';

class FriendList extends StatefulWidget {
  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  @override
  Widget build(BuildContext context) {
    var friends = Provider.of<List<AppUser>>(context) ?? [];

    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return FriendTile(name: friends[index].name, uid: friends[index].uid);
      },
    );
  }
}
