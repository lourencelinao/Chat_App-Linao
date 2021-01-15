import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/services/user_service.dart';
import 'login_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  static String id = 'register_screen';
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String email;
  String password;
  String confirm;
  bool confirmed;
  bool showSpinner = false;
  bool passwordHide = true;
  bool confirmHide = true;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Center(
          child: SafeArea(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Hero(
                          tag: 'logo',
                          child: Icon(
                            Icons.chat_bubble,
                            color: Color(0xFF006AFF),
                            size: 150.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TextFormField(
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Missing input field';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                email = value;
                              },
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                focusedErrorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue[600],
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Missing input field';
                                }
                                return null;
                              },
                              obscureText: passwordHide,
                              onChanged: (value) {
                                password = value;
                              },
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                focusedErrorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue[600],
                                    width: 2.0,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(passwordHide
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      passwordHide = !passwordHide;
                                    });
                                  },
                                ),
                                // contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                              ),
                            ),
                            TextFormField(
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Missing input field';
                                }
                                return null;
                              },
                              obscureText: confirmHide,
                              onChanged: (value) {
                                confirm = value;
                              },
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                focusedErrorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue[600],
                                    width: 2.0,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(confirmHide
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      confirmHide = !confirmHide;
                                    });
                                  },
                                ),
                                // contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            RaisedButton(
                              color: Color(0xFF006AFF),
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              onPressed: () async {
                                try {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      showSpinner = true;
                                    });
                                    confirmed = UserService()
                                        .confirmPasswordIfEqual(
                                            password, confirm);
                                    if (confirmed) {
                                      final newUser = await _auth
                                          .createUserWithEmailAndPassword(
                                              email: email, password: password);
                                      if (newUser != null) {
                                        // _firestore
                                        //     .collection('users')
                                        //     .add({'email': email});
                                        _firestore
                                            .collection('users')
                                            .doc(newUser.user.uid)
                                            .set({
                                          'email': email,
                                          'uid': newUser.user.uid
                                        });
                                        _auth.currentUser
                                            .sendEmailVerification();
                                        _showMyDialog(context, 'Success',
                                                'An email was sent to verify your account.')
                                            .then(
                                          (value) => Navigator.pushNamed(
                                              context, LoginScreen.id),
                                        );
                                      }
                                    } else {
                                      _showMyDialog(context, 'Error',
                                          'Passwords don\'t match');
                                    }
                                  }
                                  setState(() {
                                    showSpinner = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    showSpinner = false;
                                  });
                                  _showMyDialog(context, 'Error', e.message);
                                  print(e);
                                }
                              },
                              child: Text(
                                'SIGN UP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            RaisedButton(
                              // color: Color(0xFF006AFF),
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, LoginScreen.id);
                              },
                              child: Text(
                                'SIGN IN',
                                style: TextStyle(
                                  color: Color(0xFF006AFF),
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {},
                                    child: Image(
                                      image:
                                          AssetImage('images/GoogleSignUp.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {},
                                    child: Image(
                                      image: AssetImage(
                                          'images/FacebookSignUp.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showMyDialog(BuildContext context, title, body) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                body,
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Ok',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
