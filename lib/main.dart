import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/register_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/chats_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/screens/search_screen.dart';
import 'package:flash_chat/screens/forgot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData(
      //   fontFamily: 'Roboto',
      // ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        ChatsScreen.id: (context) => ChatsScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        SearchScreen.id: (context) => SearchScreen(),
        ForgotPasswordScreen.id: (context) => ForgotPasswordScreen(),
      },
    );
  }
}
