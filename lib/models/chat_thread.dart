class ChatThread {
  String participantOne, participantTwo; // uids of participants

  List<String> chatList;

  ChatThread({this.chatList, this.participantOne, this.participantTwo});
}

class ChatMessage {
  String senderName, recipientName, message, timeStamp;
  ChatMessage(
      {this.senderName, this.recipientName, this.timeStamp, this.message});
}
