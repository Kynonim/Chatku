import 'package:chatku/core/service.dart';
import 'package:chatku/uix/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignDenganGoogle extends StatelessWidget {
  SignDenganGoogle({super.key});
  final AuthService authService = AuthService();

  void signInWithGoogle(BuildContext context) async {
    User? user = await authService.loginDenganGoogle();
    if (user != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SearchUsersUI()));
    } else {
      print("Failed to sign in with Google.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: FilledButton(
          onPressed: () => signInWithGoogle(context),
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
