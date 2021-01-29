import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/nav_items/friends/friend_list.dart';
import 'package:harmony_ghosh/screens/nav_items/friends/friend_tile.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context);

    return FutureProvider<List<AppUser>>.value(
      value: DatabaseService(uid: user.uid).getFriends(),
      child: Scaffold(
        backgroundColor: Colors.white54,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0.0,
          title: Text(
            "Lobby mates",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        body: Container(
          child: FriendList(),
        ),
      ),
    );
  }
}
