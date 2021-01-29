import 'package:firebase_core/firebase_core.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/authenticate/authenticate.dart';
import 'package:harmony_ghosh/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("Firebase.initializeApp() completed");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //return either home or authenticate widget, depending upon auth status

    final user = Provider.of<AppUser>(context);
    if (user == null) {
      return Authenticate();
    } else {
      print("logged in state: redirecting to home()");
      return Home();
    }
  }
}
