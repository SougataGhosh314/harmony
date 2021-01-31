import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/models/post.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class PostTile extends StatefulWidget {
  final FeedPost post;

  PostTile({this.post});

  @override
  _PostTileState createState() => _PostTileState(post: post);
}

class _PostTileState extends State<PostTile> {
  final FeedPost post;
  _PostTileState({this.post});

  String postPicFromDB = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Card(
        margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: Column(
          children: [
            Image(
              height: 200,
              width: 350,
              image: NetworkImage(post.mediaContentURL),
              fit: BoxFit.fill,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              post.textContent,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "by " + post.creatorName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue[700]),
            ),
            SizedBox(
              height: 5,
            ),
            Text("on " + post.timeOfPost),
            SizedBox(
              height: 5,
            ),
            ListTile(
              leading: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 10,
                    primary: Colors.blue[800],
                    shadowColor: Colors.blue),
                child: Text(
                  "Like",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: () {},
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 10,
                    primary: Colors.brown[800],
                    shadowColor: Colors.amber),
                child: Text(
                  "Comment",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  // send invite her
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
