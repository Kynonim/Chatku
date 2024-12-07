import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> loginDenganGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) return null;
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleSignInAuthentication.accessToken, idToken: googleSignInAuthentication.idToken);
      final UserCredential userCredential = await auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (error) {
      print("LOGIN GOOGLE : ${error.toString()}");
      return null;
    }
  }
}