import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/screens/authenticate/image_picker.dart';
import 'package:harmony_ghosh/screens/home/my_profile.dart';
import 'package:harmony_ghosh/screens/nav_items/friends/friends.dart';
import 'package:harmony_ghosh/screens/nav_items/people/people.dart';
import 'package:harmony_ghosh/screens/nav_items/recieved_requests/recieved_requests.dart';
import 'package:harmony_ghosh/screens/nav_items/sent_requests/sent_requests.dart';
import 'package:harmony_ghosh/screens/posts/add_post.dart';
import 'package:harmony_ghosh/screens/wrapper.dart';
import 'package:harmony_ghosh/services/auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        routes: {
          "/image_picker": (context) => ImageSelector(),
          "/my_profile": (context) => MyProfile(),
          "/people": (context) => People(),
          "/friends": (context) => Friends(),
          "/sent_requests": (context) => SentRequests(),
          "/recieved_requests": (context) => RecievedRequests(),
          "/add_post": (context) => AddPost()
        },
      ),
    );
  }
}
