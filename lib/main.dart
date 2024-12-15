import 'package:chatku/core/service.dart';
import 'package:chatku/firebase_options.dart';
import 'package:chatku/uix/chat.dart';
import 'package:chatku/uix/login.dart';
import 'package:chatku/uix/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        "/chats": (context) => ChatsUI(),
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
          return FutureBuilder<bool>(
            future: AuthService.checkPermission(),
            builder: (context, permissionSnapshot) {
              if (permissionSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (permissionSnapshot.data == true) {
                return SignDenganGoogle();
              } else {
                return const Scaffold(
                  body: Center(
                    child: Text("Akses ditolak"),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}