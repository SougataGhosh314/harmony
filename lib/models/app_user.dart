class AppUser {
  final String uid, name, phoneNumber, profileImageUrl;

  final List<String> friends, incomingRequests, outgoingRequests;

  final List<String> posts;

  AppUser(
      {this.uid,
      this.name,
      this.phoneNumber,
      this.profileImageUrl,
      this.friends,
      this.incomingRequests,
      this.outgoingRequests,
      this.posts});
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
