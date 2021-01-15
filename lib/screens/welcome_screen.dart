import 'package:flutter/material.dart';
import 'package:flash_chat/screens/register_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 100.0, 0, 0),
                child: Hero(
                  tag: 'logo',
                  child: Icon(
                    Icons.chat_bubble,
                    color: Color(0xFF006AFF),
                    size: 150.0,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Connect Together',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
                child: Text(
                  'Lorem ipsum dolor sit amet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 50.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RaisedButton(
                        color: Color(0xFF006AFF),
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 75.0),
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, RegisterScreen.id);
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, LoginScreen.id);
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: Color(0xFF0041FD),
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
