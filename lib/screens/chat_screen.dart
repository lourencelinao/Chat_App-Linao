import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

var borderSetting = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.grey, width: 2),
  borderRadius: BorderRadius.all(
    Radius.circular(0),
  ),
);

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
bool isMe;

String getLargerAndConcat(uid1, uid2) {
  String uid;
  if (_auth.currentUser.uid.compareTo(uid2) == 1) {
    uid = uid1 + uid2;
  } else {
    uid = uid2 + uid1;
  }
  return uid;
}

class ChatScreen extends StatefulWidget {
  ChatScreen({this.email, this.uid});
  final email, uid;
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String message;
  final messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.email),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            MessageStream(
              email: widget.email,
              uid: widget.uid,
            ),
            Material(
              elevation: 5,
              child: TextField(
                // inputFormatters: [],
                controller: messageTextController,
                onChanged: (value) async {
                  message = value;
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  suffix: FlatButton(
                    onPressed: () {
                      if (message.isNotEmpty) {
                        messageTextController.clear();
                        String uid = getLargerAndConcat(
                            _auth.currentUser.uid, widget.uid);

                        _firestore
                            .collection('conversation')
                            .doc(uid)
                            .collection('messages')
                            .add({
                          'sender': _auth.currentUser.email,
                          'text': message,
                          'timestamp': DateTime.now()
                        });
                      }
                    },
                    child: Text(
                      'Send',
                      style: TextStyle(
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                  hintText: 'Type a message',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  MessageStream({@required this.email, @required this.uid});
  final email, uid;
  @override
  Widget build(BuildContext context) {
    final documentId = getLargerAndConcat(_auth.currentUser.uid, uid);
    print(documentId);
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('conversation')
            .doc(documentId)
            .collection('messages')
            .orderBy(
              'timestamp',
              descending: false,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent),
            );
          }
          print(snapshot);
          final messages = snapshot.data.docs.reversed;
          List<MessageBox> messageBoxes = [];
          for (var message in messages) {
            final text = message.data()['text'];
            final sender = message.data()['sender'];
            final messageBox = MessageBox(
              message: text,
              sender: sender,
            );

            messageBoxes.add(messageBox);
          }

          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 15.0),
              child: snapshot.data.docs.isNotEmpty
                  ? ListView(
                      reverse: true,
                      children: messageBoxes,
                    )
                  : Center(
                      child: Text(
                        'You can now start a conversation with this person.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          );
        });
  }
}

class MessageBox extends StatelessWidget {
  MessageBox({this.message, this.sender});
  final message, sender;
  @override
  Widget build(BuildContext context) {
    isMe = sender == _auth.currentUser.email;
    var borderRadiusSetting = isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0))
        : BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 250),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[600] : Colors.grey[300],
              borderRadius: borderRadiusSetting,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 2.0,
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
