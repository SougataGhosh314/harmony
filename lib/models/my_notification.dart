class MyNotification {
  String ownerId; // id of person for which noti. is meant
  String type;
  // sent friend request: "0"
  // accept friend request: "1"
  // liked your post: "2"
  // commented on your post: "3"
  // friend added a post: "4"
  String fromWhomId, fromWhomName;
  // from where the noti. is generated, e.g., "who commented on your post?": some uid
  String postId;
  // kept empty: "" for type 0 and 1,
  // used for 2, 3 and 4
  String timeStamp; // epoch time when generating and normal time when reading

  MyNotification(
      {this.ownerId, this.fromWhomId, this.fromWhomName, this.postId,
      this.timeStamp, this.type}
      );
}

// above doc will be saved with id:

// "ownerId_timeStamp"
// and also under notifications list for owner
