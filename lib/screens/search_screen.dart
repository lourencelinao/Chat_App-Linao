import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
var newContact;

class SearchScreen extends StatefulWidget {
  SearchScreen({this.user});
  final user;
  static String id = 'SearchScreen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    newContact = widget.user;
    print(widget.user);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Result',
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 25.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _showMyDialog(context, 'Add contact',
                          'Would you like to add ${widget.user['email']}');
                    },
                    child: Text(
                      widget.user['email'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              )
            ],
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
              'No',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () async {
              if (newContact['email'] == _auth.currentUser.email) {
                Navigator.of(context).pop();
                _showMyDialogError(context, 'Error', 'You can\'t add yourself');
              } else {
                _firestore
                    .collection('users')
                    .doc(_auth.currentUser.uid)
                    .collection('contacts')
                    .where('uid', isEqualTo: newContact['uid'])
                    .get()
                    .then(
                  (value) {
                    if (value.docs.isEmpty) {
                      _firestore
                          .collection('users')
                          .doc(_auth.currentUser.uid)
                          .collection('contacts')
                          .add(
                        {
                          'email': newContact['email'],
                          'uid': newContact['uid'],
                        },
                      );

                      _firestore
                          .collection('users')
                          .doc(newContact['uid'])
                          .collection('contacts')
                          .add(
                        {
                          'email': _auth.currentUser.email,
                          'uid': _auth.currentUser.uid,
                        },
                      );

                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    } else {
                      Navigator.of(context).pop();
                      _showMyDialogError(context, 'Failed',
                          'You both already have a connection');
                    }
                  },
                );

                // if (user == null) {
                //   print('peepoo');
                // } else {
                //   Navigator.of(context).pop();
                //   _showMyDialogError(
                //       context, 'Failed', 'You both already have a connection');
                // }
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showMyDialogError(BuildContext context, title, body) async {
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
              'Okay',
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
