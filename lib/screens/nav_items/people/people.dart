import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/nav_items/people/people_list.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:provider/provider.dart';

class People extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<AppUser>>.value(
      value: DatabaseService().users,
      child: Scaffold(
        backgroundColor: Colors.white54,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0.0,
          title: Text(
            "People",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        body: Container(
            // decoration: BoxDecoration(
            //     image: DecorationImage(
            //         image: AssetImage("assets/coffee_bg.png"), fit: BoxFit.cover),
            //   ),
            child: PeopleList()),
      ),
    );
  }
}
