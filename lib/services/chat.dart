import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harmony_ghosh/models/chat_thread.dart';

class ChatService {
  final String senderId, recipientId;
  ChatService({this.senderId, this.recipientId});

  final CollectionReference reference =
      FirebaseFirestore.instance.collection("appusers");

  final CollectionReference chatThreadsReference =
      FirebaseFirestore.instance.collection("chatthreads");

  List<String> dynamicListToStringList(List<dynamic> list) {
    List<String> toReturn = [];

    list.forEach((item) {
      toReturn.add(item.toString());
    });

    return toReturn;
  }

  Future getNameFromDB(String uid) async {
    String name = await reference.doc(uid).get().then((sp) {
      //print("Found one: " + sp.data()["name"].toString());
      // friendName = sp.data()["name"].toString();
      // print(friendName);
      return sp.data()["name"].toString();
    });

    return name;
  }

  List<ChatMessage> getList(DocumentSnapshot ds) {
    List<ChatMessage> list = [];
    print("inside getList");

    if (ds.get("chatList").length != 0) {
      List<String> stringList = dynamicListToStringList(ds.get("chatList"));
      for (int i = 0; i < stringList.length; i++) {
        String senderName = ds.get("chatList")[i].split("_")[0];
        //await getNameFromDB(ds.data()["chatList"][i].split("_")[0]);
        String recipientName = ds.get("chatList")[i].split("_")[1];
        //await getNameFromDB(ds.data()["chatList"][i].split("_")[1]);
        String timeStamp = DateTime.fromMillisecondsSinceEpoch(
                int.parse(stringList[i].split("_")[2]))
            .toString();
        String message = stringList[i].split("_")[3];
        print("message::: " + message);

        list.add(ChatMessage(
            senderName: senderName,
            recipientName: recipientName,
            timeStamp: timeStamp,
            message: message));
      }
    }

    return list;
  }

  Stream<List<ChatMessage>> get getChatThreadMessagesRS {
    return chatThreadsReference
        .doc(recipientId + "_" + senderId)
        .snapshots()
        .map(getList);
  }

  Stream<List<ChatMessage>> get getChatThreadMessagesSR {
    return chatThreadsReference
        .doc(senderId + "_" + recipientId)
        .snapshots()
        .map(getList);

    // Stream<List<ChatMessage>> myStream;
    // bool done = false;
    // print("inside getChatThreadMessages " + senderId + "_" + recipientId);
    // chatThreadsReference
    //     .doc(senderId + "_" + recipientId)
    //     .get()
    //     .then((DocumentSnapshot ds) async {
    //   if (ds.exists) {
    //     print("senderId_recipientId");
    //     done = true;
    //     return chatThreadsReference
    //         .doc(senderId + "_" + recipientId)
    //         .snapshots()
    //         .map(getList);
    //   }
    // });

    // if (!done) {
    //   chatThreadsReference
    //       .doc(recipientId + "_" + senderId)
    //       .get()
    //       .then((DocumentSnapshot ds) async {
    //     if (ds.exists) {
    //       print("recipientId_senderId");
    //       done = true;
    //       getList(ds);

    //       // chatThreadsReference
    //       //     .doc(recipientId + "_" + senderId)
    //       //     .get()
    //       //     .then((DocumentSnapshot ds) {
    //       //   // List<String> tempList =
    //       //   //     dynamicListToStringList(ds.data()["chatlist"]);
    //       //   print(ds.data()["chatList"].length);
    //       //   //tempList.forEach((item) => print(item));
    //       // });

    //       return chatThreadsReference
    //           .doc(recipientId + "_" + senderId)
    //           .snapshots()
    //           .map(getList);

    //       //print("myStream:: " + myStream.toString());

    //       //return myStream;
    //     }
    //   });
    // }

    //print("reached here");
    // print("chat list at the end: " + list.toString());
    // return list;
    //return myStream;
  }
}
