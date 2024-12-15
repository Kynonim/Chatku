import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Static {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static Reference storageReference = storage.ref("rikyxdz");
  static DatabaseReference usersReference = FirebaseDatabase.instance.ref("rikyxdz");
  static DatabaseReference chatsReference = FirebaseDatabase.instance.ref("chats");

  static String? uid = auth.currentUser?.uid;

  static void TampilkanWidget(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}