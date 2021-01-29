import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/nav_items/people/person_tile.dart';
import 'package:provider/provider.dart';

class PeopleList extends StatefulWidget {
  @override
  _PeopleListState createState() => _PeopleListState();
}

class _PeopleListState extends State<PeopleList> {
  @override
  Widget build(BuildContext context) {
    var users = Provider.of<List<AppUser>>(context) ?? [];
    AppUser me = Provider.of<AppUser>(context);
    users.removeWhere((item) => item.uid == me.uid);

    // return FutureBuilder(
    //   future: DatabaseService().friends;
    // );

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return PersonTile(name: users[index].name, uid: users[index].uid);
      },
    );
  }
}
