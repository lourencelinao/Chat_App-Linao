import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'chats_screen.dart';
import 'register_screen.dart';
import 'forgot_screen.dart';


class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  bool showSpinner = false;
  bool passwordHide = true;
  final _auth = FirebaseAuth.instance;
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
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, ForgotPasswordScreen.id);
                              },
                              child: Container(
                                padding: EdgeInsets.all(15.0),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
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
                                    final user =
                                        await _auth.signInWithEmailAndPassword(
                                            email: email, password: password);
                                    if (user != null) {
                                      if (_auth.currentUser.emailVerified) {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            ChatsScreen.id,
                                            (r) => false);
                                      } else {
                                        _auth.currentUser
                                            .sendEmailVerification();
                                        _showMyDialog(context, 'Error',
                                            'Account is not yet verified. Sent another verification email.');
                                      }
                                    }
                                    setState(() {
                                      showSpinner = false;
                                    });
                                    // Scaffold.of(context).showSnackBar(
                                    //     SnackBar(content: Text('Processing Data')));
                                  }
                                } catch (e) {
                                  print(e.message);
                                  setState(() {
                                    showSpinner = false;
                                  });
                                  _showMyDialog(context, 'Error', e.message);
                                }
                              },
                              child: Text(
                                'LOG IN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            RaisedButton(
                              color: Colors.grey,
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, RegisterScreen.id);
                              },
                              child: Text(
                                'CREATE NEW ACCOUNT',
                                style: TextStyle(
                                  color: Colors.white,
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
