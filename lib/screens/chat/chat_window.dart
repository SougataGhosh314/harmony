import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harmony_ghosh/models/chat_thread.dart';
import 'package:harmony_ghosh/services/chat.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Map data = {};
  String myMessage = "";
  final CollectionReference chatThreadsReference =
      FirebaseFirestore.instance.collection("chatthreads");
  bool found = false;
  Stream<List<ChatMessage>> listenTo;

  String myProfilePicFromDB = "";
  String buddyProfilePicFromDB = "";
  NetworkImage myImage, buddyImage;

  Future getDownloadURL(String myUid, String buddyUid) async {
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref();
    String imageName = "profile_images/" + "$myUid" + ".png";
    String imageName2 = "profile_images/" + "$buddyUid" + ".png";
    print(imageName);
    String url = await ref.child(imageName).getDownloadURL();
    String url2 = await ref.child(imageName2).getDownloadURL();
    print("Url recieved: $url");
    setState(() {
      myProfilePicFromDB = url;
      myImage = NetworkImage(url);
      buddyProfilePicFromDB = url2;
      buddyImage = NetworkImage(url2);
    });
  }

  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    data = data.isNotEmpty ? data : ModalRoute.of(context).settings.arguments;

    String senderId = data["me"].uid;
    String recipientId = data["buddyId"];
    String buddyName = data["buddyName"];

    // listenTo = ChatService(recipientId: recipientId, senderId: senderId)
    //     .getChatThreadMessagesRS;

    if (!found) {
      chatThreadsReference.doc(senderId + "_" + recipientId).get().then((ds) {
        if (ds.exists) {
          setState(() {
            listenTo = ChatService(recipientId: recipientId, senderId: senderId)
                .getChatThreadMessagesSR;
            found = true;
          });
        }
      });
    }

    if (!found) {
      chatThreadsReference.doc(recipientId + "_" + senderId).get().then((ds) {
        if (ds.exists) {
          setState(() {
            listenTo = ChatService(recipientId: recipientId, senderId: senderId)
                .getChatThreadMessagesRS;
            found = true;
          });
        }
      });
    }

    String imageURL =
        "https://cdn.pixabay.com/photo/2013/08/26/11/04/quill-175980_960_720.png";
    String imageURL2 = imageURL;

    if (myProfilePicFromDB == "" || buddyProfilePicFromDB == "") {
      getDownloadURL(senderId, recipientId);
    }

    if (myProfilePicFromDB != "" && buddyProfilePicFromDB != "") {
      imageURL = myProfilePicFromDB;
      imageURL2 = buddyProfilePicFromDB;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Chat with " + buddyName),
      ),
      body: StreamBuilder<List<ChatMessage>>(
        stream: listenTo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ChatMessage> chatList = snapshot.data;
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);

            return ListView.builder(
              controller: _scrollController,
              reverse: false,
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                if (chatList[index].senderName == senderId) {
                  return NewWidget(
                      myImage: myImage, chatList: chatList, index: index);
                } else if (chatList[index].senderName == recipientId) {
                  return NewWidget2(
                      buddyImage: buddyImage, chatList: chatList, index: index);
                } else {
                  return NewWidget(
                      myImage: myImage, chatList: chatList, index: index);
                }
              },
            );
          } else {
            return ListView.builder(
              controller: _scrollController,
              reverse: false,
              itemCount: 1,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Say hi to your friend",
                    style: TextStyle(
                        color: Colors.blue[500],
                        fontStyle: FontStyle.italic,
                        fontSize: 24),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.only(bottom: bottom),
        child: BottomAppBar(
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: TextFormField(
                    initialValue: "",
                    keyboardType: TextInputType.multiline,
                    decoration:
                        textInputDecoration.copyWith(hintText: "Your message"),
                    onChanged: (val) {
                      setState(() {
                        myMessage = val;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: ElevatedButton(
                    child: Text("Send"),
                    onPressed: () async {
                      if (myMessage != "") {
                        await DatabaseService(uid: senderId)
                            .sendMessage(recipientId, myMessage);

                        Fluttertoast.showToast(
                            msg: "message sent",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER);

                        setState(() {
                          if (found == false) {
                            chatThreadsReference
                                .doc(senderId + "_" + recipientId)
                                .get()
                                .then((ds) {
                              if (ds.exists) {
                                listenTo = ChatService(
                                        recipientId: recipientId,
                                        senderId: senderId)
                                    .getChatThreadMessagesSR;
                                found = true;
                              }
                            });
                          }

                          if (!found) {
                            chatThreadsReference
                                .doc(recipientId + "_" + senderId)
                                .get()
                                .then((ds) {
                              if (ds.exists) {
                                setState(() {
                                  listenTo = ChatService(
                                          recipientId: recipientId,
                                          senderId: senderId)
                                      .getChatThreadMessagesRS;
                                  found = true;
                                });
                              }
                            });
                          }
                        });
                      } else {
                        Fluttertoast.showToast(
                            msg: "can't leave empty",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget({
    Key key,
    @required this.myImage,
    @required this.chatList,
    @required this.index,
  }) : super(key: key);

  final NetworkImage myImage;
  final List<ChatMessage> chatList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.blue[100],
      margin: EdgeInsets.fromLTRB(10, 6, 10, 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: myImage,
          radius: 25,
          backgroundColor: Colors.red,
        ),
        title: Text(
          chatList[index].message,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        subtitle: Text(
          chatList[index].timeStamp,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green, fontSize: 10),
        ),
      ),
    );
  }
}

class NewWidget2 extends StatelessWidget {
  const NewWidget2({
    Key key,
    @required this.buddyImage,
    @required this.chatList,
    @required this.index,
  }) : super(key: key);

  final NetworkImage buddyImage;
  final List<ChatMessage> chatList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.blue[100],
      margin: EdgeInsets.fromLTRB(10, 6, 10, 0),
      child: ListTile(
        title: Text(
          chatList[index].message,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        subtitle: Text(
          chatList[index].timeStamp,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green, fontSize: 10),
        ),
        trailing: CircleAvatar(
          backgroundImage: buddyImage,
          radius: 25,
          backgroundColor: Colors.red,
        ),
      ),
    );
  }
}
