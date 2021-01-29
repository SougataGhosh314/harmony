import 'package:firebase_core/firebase_core.dart';
import 'package:harmony_ghosh/services/auth.dart';
import 'package:harmony_ghosh/shared/constants.dart';
import 'package:harmony_ghosh/shared/loading.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // @override
  // void initState() {
  //   super.initState();
  //   Firebase.initializeApp().whenComplete(() {
  //     print("Firebase.initializeApp() completed");
  //     setState(() {});
  //   });
  // }

  //final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
              title: Text('Sign in'),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  label: Text("Register"),
                  onPressed: () {
                    //widget.toggleView();
                  },
                )
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                //key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: "password"),
                      obscureText: true,
                      onChanged: (val) {
                        setState(() => {password = val});
                      },
                      validator: (val) =>
                          val.length < 6 ? "Enter a password > 6 chars" : null,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      color: Colors.black45,
                      child: Text(
                        "Sign in",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        // if (_formKey.currentState.validate()) {
                        //   setState(() {
                        //     loading = true;
                        //   });
                        //   dynamic result = await _auth
                        //       .signInWithEmailAndPassword(email, password);
                        //   if (result == null) {
                        //     setState(() {
                        //       loading = false;
                        //       error = "Please supply valid credentials";
                        //     });
                        //   }
                        // } else {}
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
