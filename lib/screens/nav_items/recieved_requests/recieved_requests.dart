import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/nav_items/recieved_requests/recieved_request_list.dart';
import 'package:harmony_ghosh/screens/nav_items/recieved_requests/recieved_request_tile.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:provider/provider.dart';

class RecievedRequests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context);

    return FutureProvider<List<AppUser>>.value(
      value: DatabaseService(uid: user.uid).getRecievedRequests(),
      child: Scaffold(
        backgroundColor: Colors.white54,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0.0,
          title: Text(
            "Recieved requests",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        body: Container(
          child: RecievedRequestList(),
        ),
      ),
    );
  }
}
