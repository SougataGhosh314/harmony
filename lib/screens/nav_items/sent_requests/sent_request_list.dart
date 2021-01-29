import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/nav_items/sent_requests/sent_request_tile.dart';
import 'package:provider/provider.dart';

class SentRequestList extends StatefulWidget {
  @override
  _SentRequestListState createState() => _SentRequestListState();
}

class _SentRequestListState extends State<SentRequestList> {
  @override
  Widget build(BuildContext context) {
    var users = Provider.of<List<AppUser>>(context) ?? [];

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return SentRequestTile(name: users[index].name, uid: users[index].uid);
      },
    );
  }
}
