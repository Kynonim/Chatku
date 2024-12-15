import 'package:chatku/core/statis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> loginDenganGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) return null;
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleSignInAuthentication.accessToken, idToken: googleSignInAuthentication.idToken);
      final UserCredential userCredential = await Static.auth.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        await Static.usersReference.child(user.uid).set({
          "uid": user.uid,
          "name": user.displayName,
          "email": user.email,
          "photo": user.photoURL,
          "online": {
            "status": true,
            "time": DateTime.now().toIso8601String(),
          },
        });
      }

      return userCredential.user;
    } catch (error) {
      print("LOGIN GOOGLE : ${error.toString()}");
      return null;
    }
  }

  Future<void> logout() async {
    await Static.auth.signOut();
    await googleSignIn.signOut();
    await Static.usersReference.child("rikyxdz/${Static.auth.currentUser!.uid}").update({"online": false});
  }

  static Future<bool> checkPermission() async {
    if (await Permission.storage.request().isGranted && await Permission.camera.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }
}