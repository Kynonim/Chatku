import 'package:chatku/core/statis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        await Static.dbReference.child(user.uid).set({
          "uid": user.uid,
          "name": user.displayName,
          "email": user.email,
          "photo": user.photoURL,
          "online": true,
          "chats": {}
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
    await Static.dbReference.child("rikyxdz/${Static.auth.currentUser!.uid}").update({"online": false});
  }
}