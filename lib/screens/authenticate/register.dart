import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:harmony_ghosh/models/app_user.dart';
import 'package:harmony_ghosh/services/auth.dart';
import 'package:harmony_ghosh/services/database.dart';
import 'package:harmony_ghosh/shared/constants.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // @override
  // void initState() {
  //   super.initState();
  //   Firebase.initializeApp().whenComplete(() {
  //     print("Firebase.initializeApp() completed");
  //     setState(() {});
  //   });
  // }

  // final AuthService _auth = AuthService();
  // final _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  bool VISIBILITY = false;

  // text field state
  //String name = "";
  String phone = "";
  String error = "";
  String smsCode = "", verID = "";

  Future logInWithOTP(String smsCode, String verID) async {
    PhoneAuthCredential phoneAuthCredential =
        PhoneAuthProvider.credential(verificationId: verID, smsCode: smsCode);
    UserCredential cred = await _auth.signInWithCredential(phoneAuthCredential);

    DatabaseService(uid: cred.user.uid).updateUserData();
    //print("CCCCCRRRREEEEDDDD: ${cred.user}");
  }

  Future verifyPhone(String phone) async {
    try {
      _auth.verifyPhoneNumber(
        phoneNumber: "+91" + phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // on complete
          UserCredential cred = await _auth.signInWithCredential(credential);
          DatabaseService(uid: cred.user.uid).updateUserData();
          //print("CCCCCRRRREEEEDDDD");
          //print("CCCCCRRRREEEEDDDD auto:    ${cred.user}");
          //print("Auth result: ${result.toString()}");
        },
        verificationFailed: (FirebaseAuthException e) {
          // on failed
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int resendToken) async {
          // on code sent
          print("Code was sent to $phone");
          setState(() {
            verID = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // auto retrieval timeout
          print("Auto-resolution timed out...");
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
              title: Text('Register'),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  label: Text("Sign in"),
                  onPressed: () {
                    widget.toggleView();
                  },
                )
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Column(
                children: [
                  Form(
                    //key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          initialValue: phone ?? "",
                          keyboardType: TextInputType.phone,
                          decoration: textInputDecoration.copyWith(
                              hintText: "phone number"),
                          onChanged: (val) {
                            setState(() => {phone = val});
                          },
                          validator: (val) =>
                              val.isEmpty ? "Enter your phone" : null,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RaisedButton(
                          color: Colors.black45,
                          child: Text(
                            "Verify phone",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (phone.length != 10) {
                              print(phone);
                              Fluttertoast.showToast(
                                msg: "Enter a valid phone",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                              );
                            } else {
                              print(phone);
                              setState(() {
                                VISIBILITY = true;
                              });
                              // call phoneAuth here
                              await verifyPhone(phone);
                            }
                          },
                        ),
                        Visibility(
                          visible: VISIBILITY,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                initialValue: smsCode,
                                keyboardType: TextInputType.number,
                                decoration: textInputDecoration.copyWith(
                                    hintText: "verification code"),
                                onChanged: (val) {
                                  setState(() => {smsCode = val});
                                },
                                validator: (val) =>
                                    val.isEmpty ? "Enter your code" : null,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              RaisedButton(
                                color: Colors.black45,
                                child: Text(
                                  "Submit code",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  // code entered
                                  await logInWithOTP(smsCode, verID);
                                },
                              ),
                            ],
                          ),
                        ),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
