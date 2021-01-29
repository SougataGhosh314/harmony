import 'package:firebase_core/firebase_core.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  // AuthService() {
  //   Firebase.initializeApp().whenComplete(() {
  //     _auth = FirebaseAuth.instance;
  //   });
  // }

  AppUser _userFromFirebaseUser(User user) {
    return user != null
        ? AppUser(
            name: "",
            phoneNumber: user.phoneNumber,
            profileImageUrl: "",
            uid: user.uid,
            friends: [],
            incomingRequests: [],
            outgoingRequests: [],
            posts: [])
        : null;
  }

  Stream<AppUser> get user {
    return FirebaseAuth.instance.authStateChanges().map(_userFromFirebaseUser);
  }

  Future signOut() async {
    await _auth.signOut();
  }

  // AppUser currentUser;
  // AuthService({this.currentUser});

  // Future verifyPhone(String phone) async {
  //   try {
  //     _auth.verifyPhoneNumber(
  //       phoneNumber: "+91" + phone,
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         // on complete
  //         await _auth.signInWithCredential(credential);
  //       },
  //       verificationFailed: (FirebaseAuthException e) {
  //         // on failed
  //         if (e.code == 'invalid-phone-number') {
  //           print('The provided phone number is not valid.');
  //         }
  //       },
  //       codeSent: (String verificationId, int resendToken) async {
  //         // on code sent
  //         print("Code was sent to $phone");
  //         // Update the UI - wait for the user to enter the SMS code

  //         String smsCode = 'xxxx';
  //         // needs work above

  //         // Create a PhoneAuthCredential with the code
  //         PhoneAuthCredential phoneAuthCredential =
  //             PhoneAuthProvider.credential(
  //                 verificationId: verificationId, smsCode: smsCode);

  //         // Sign the user in (or link) with the credential
  //         await _auth.signInWithCredential(phoneAuthCredential);
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //         // auto retrieval timeout
  //         print("Auto-resolution timed out...");
  //       },
  //     );
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // // create custom user object based on firebase user
  // User _userFromFirebaseUser(FirebaseUser user) {
  //   return user != null ? User(uid: user.uid, email: user.email) : null;
  // }

  // // auth change: user stream
  // Stream<User> get user {
  //   return _auth.onAuthStateChanged
  //       .map(_userFromFirebaseUser); // same as below line
  //   //.map((FirebaseUser user) => _userFromFirebaseUser(user));
  // }

  // // sign in anonymously
  // Future signInAnon() async {
  //   try {
  //     AuthResult result = await _auth.signInAnonymously();
  //     FirebaseUser user = result.user;
  //     return _userFromFirebaseUser(user);
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  // // sign in with email and password
  // Future signInWithEmailAndPassword(String email, String password) async {
  //   try {
  //     AuthResult result = await _auth.signInWithEmailAndPassword(
  //         email: email, password: password);
  //     FirebaseUser user = result.user;
  //     // print(user.email);
  //     return _userFromFirebaseUser(user);
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  // register with email and password
  // Future registerWithEmailAndPassword(String email, String password) async {
  //   try {
  //     AuthResult result = await _auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     FirebaseUser user = result.user;

  //     // create a new document for this user with it's uid
  //     await DatabaseService(uid: user.uid)
  //         .updateUserData("0", "new member", 100);

  //     return _userFromFirebaseUser(user);
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  // // sign out
  // Future signOut() async {
  //   try {
  //     return await _auth.signOut();
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }
}
