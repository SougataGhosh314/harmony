class AppUser {
  final String uid, name, phoneNumber, profileImageUrl, bio;

  final List<String> friends, incomingRequests, outgoingRequests;

  final List<String> posts, notifications;

  AppUser(
      {this.uid,
      this.name,
      this.phoneNumber,
      this.profileImageUrl,
      this.bio,
      this.friends,
      this.incomingRequests,
      this.outgoingRequests,
      this.posts,
      this.notifications});
}

class AnotherUser {
  final String uid, name, profileImageUrl, bio;

  final List<String> mutualFriendIds, mutualFriendNames;

  final List<String> publicPosts;

  AnotherUser(
      {this.uid,
      this.name,
      this.mutualFriendIds,
      this.profileImageUrl,
      this.bio,
      this.mutualFriendNames,
      this.publicPosts});
}

// class AnotherUser {
//   String uid;
//   AnotherUser({this.uid});
// }

// class User {
//   final String uid;
//   final String email;

//   User({this.uid, this.email});
// }

// class UserData {
//   final String name, sugars, uid, profilepicurl;
//   final int strength;

//   UserData(
//       {this.name, this.uid, this.strength, this.sugars, this.profilepicurl});
// }

// class ProfileData {
//   final String uid, profile_pic_url;
//   ProfileData({this.uid, this.profile_pic_url});
// }
