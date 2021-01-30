class Post {
  String postId; // post id: userID_creationTimeStamp
  String creatorId; // stores user id of creator
  String textContent; // stores the text content made in the post
  String mediaContentURL;
  // stores the URL of the photo/video in the post, if there
  // conveniently it is the download URL of file
  // posts/postId.png

  List<String> likes; // stores the userIds of people who liked the post
  List<String> comments;
  // stores the comment in format:
  // userIdofCommenter_timeStampOfComment_commentWritten

  String visibility;
  // "private", "friends" or "public"

  Post(
      {this.postId,
      this.creatorId,
      this.textContent,
      this.mediaContentURL,
      this.visibility,
      this.comments,
      this.likes});
}

class FeedPost {
  String postId; // post id: userID_creationTimeStamp
  String creatorName; // stores user id of creator
  String textContent; // stores the text content made in the post
  String mediaContentURL;
  String timeOfPost;
  // stores the URL of the photo/video in the post, if there
  // conveniently it is the download URL of file
  // posts/postId.png

  List<String> likes; // stores the userIds of people who liked the post
  List<String> comments;
  // stores the comment in format:
  // userIdofCommenter_timeStampOfComment_commentWritten

  FeedPost(
      {this.postId,
      this.creatorName,
      this.textContent,
      this.mediaContentURL,
      this.timeOfPost,
      this.comments,
      this.likes});
}
