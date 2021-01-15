import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

var borderSetting = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.grey, width: 2),
  borderRadius: BorderRadius.all(
    Radius.circular(10),
  ),
);

class ForgotPasswordScreen extends StatefulWidget {
  static String id = 'ForgotPasswordScreen';

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  var email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Missing input';
                  }
                  return null;
                },
                onChanged: (value) {
                  email = value;
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 8.0,
                  ),
                  hintText: 'Email',
                  enabledBorder: borderSetting,
                  focusedBorder: borderSetting,
                  focusedErrorBorder: borderSetting,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: () async {
                  try {
                    if (_formKey.currentState.validate()) {
                      await _auth.sendPasswordResetEmail(email: email);
                      await _showMyDialog(context, 'Success',
                          'An email has been sent to your email address');
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print(e.message);
                    _showMyDialog(context, 'Error', e.message);
                  }
                },
                padding: EdgeInsets.all(
                  15.0,
                ),
                color: Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Send Password Reset Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
              ),
            )
          ],
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
