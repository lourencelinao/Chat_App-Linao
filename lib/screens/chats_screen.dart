import 'dart:async';
import 'search_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:email_validator/email_validator.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
bool showSpinner = false;

var borderSetting = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.grey, width: 2),
  borderRadius: BorderRadius.all(
    Radius.circular(10),
  ),
);

class ChatsScreen extends StatefulWidget {
  static String id = 'chats_screen';
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String search;
  String result;
  Timer timeHandle;
  int _currentIndex = 0;
  final messageInputController = TextEditingController();
  var user;
  bool itExist = false;

  Future<void> getUser(email) async {
    await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      for (var temp in value.docs) {
        user = temp.data();
        itExist = true;
        print(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.search,
              controller: messageInputController,
              onEditingComplete: () async {
                showSpinner = true;
                await getUser(search);
                if (itExist) {
                  print('it exist');
                  messageInputController.clear();
                  FocusScope.of(context).unfocus();
                  search = '';
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return SearchScreen(
                        user: user,
                      );
                    }),
                  );
                } else {
                  _showMyDialog(context, '', 'User not found');
                }
                showSpinner = false;
                print(itExist);
                itExist = false;
              },
              onChanged: (value) async {
                search = value;
              },
              style: TextStyle(
                color: Colors.black,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                hintText: 'Search here',
                enabledBorder: borderSetting,
                focusedBorder: borderSetting,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 15.0),
                child: ContactStream(),
              ),
            ),
          ],
        ),
      ),
      //This is the 2nd tab
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            CircularProfileAvatar(
              '',
              child: FittedBox(
                child: Image.asset('images/baby_yoda.jpg'),
                fit: BoxFit.cover,
              ),
              borderColor: Colors.purpleAccent,
              borderWidth: 5,
              elevation: 2,
              radius: 120,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              _auth.currentUser.email,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: RaisedButton(
                      onPressed: () {
                        _auth.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginScreen.id, (route) => false);
                      },
                      child: Text(
                        'SIGN OUT',
                        style: TextStyle(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Conversations'),
        backgroundColor: Colors.blueAccent[900],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: _widgetOptions.elementAt(_currentIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF006AFF),
        unselectedItemColor: Colors.black.withOpacity(.60),
        selectedFontSize: 15,
        unselectedFontSize: 15,
        currentIndex: _currentIndex,
        onTap: (value) {
          // Respond to item press.
          setState(() => _currentIndex = value);
        },
        items: [
          BottomNavigationBarItem(
            label: 'Messages',
            icon: Icon(Icons.chat),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}

class ContactStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser.uid)
          .collection('contacts')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent),
          );
        }
        final contacts = snapshot.data.docs;
        print('test $contacts');
        List<ContactBox> contactBoxes = [];
        for (var contact in contacts) {
          final email = contact.data()['email'];
          final uid = contact.data()['uid'];
          final contactBox = ContactBox(email: email, uid: uid);
          contactBoxes.add(contactBox);
        }
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
            child: snapshot.data.docs.isNotEmpty
                ? ListView(
                    children: contactBoxes,
                  )
                : Center(
                    child: Text(
                      'You have no contacts as of the moment.',
                      style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class ContactBox extends StatelessWidget {
  ContactBox({this.email, this.uid});
  final email;
  final uid;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatScreen(email: email, uid: uid);
          }));
        },
        child: Text(
          email,
          style: TextStyle(
            color: Colors.black,
            fontSize: 25.0,
          ),
          textAlign: TextAlign.left,
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
