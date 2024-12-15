import 'package:chatku/core/service.dart';
import 'package:chatku/dev/gemini.dart';
import 'package:chatku/firebase_options.dart';
import 'package:chatku/uix/chat.dart';
import 'package:chatku/uix/login.dart';
import 'package:chatku/uix/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.checkPermission();
  await dotenv.load(fileName: ".env");
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatku',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: "/",
      routes: {
        "/": (context) => const AuthCheck(),
        "/login": (context) => SignDenganGoogle(),
        "/users": (context) => SearchUsersUI(),
        "/chats": (context) => const ChatsUI(),
        "/gemini": (context) => const GeminiAI(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return SearchUsersUI();
        } else {
          return SignDenganGoogle();
        }
      },
    );
  }
}