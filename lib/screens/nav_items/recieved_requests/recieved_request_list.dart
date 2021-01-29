import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/nav_items/recieved_requests/recieved_request_tile.dart';
import 'package:provider/provider.dart';

class RecievedRequestList extends StatefulWidget {
  @override
  _RecievedRequestListState createState() => _RecievedRequestListState();
}

class _RecievedRequestListState extends State<RecievedRequestList> {
  @override
  Widget build(BuildContext context) {
    var users = Provider.of<List<AppUser>>(context) ?? [];

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return RecievedRequestTile(
            name: users[index].name, uid: users[index].uid);
      },
    );
  }
}
