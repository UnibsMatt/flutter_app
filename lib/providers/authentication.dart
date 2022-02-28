import 'package:firebase_auth/firebase_auth.dart';
import 'package:orobix_manager/providers/firestore.dart';
import 'package:flutter/cupertino.dart';

class FirebaseAuthManager extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserCredential? _userCredential;

  String get userID => _userCredential!.user!.uid;
  String? get userName => _userCredential!.user!.displayName;

  Future<String?> getUserName() async {
    return await FirebaseStoreManager().getUserName(userID);
  }

  Future<String?> register(String email, String password, String name, String surname) async {
    try {
      _userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseException catch (e) {
      switch(e.code){
        case "email-already-in-use":
          return "Email is already in use";
      }
      return "Error during the creation of the user";
    }
    FirebaseStoreManager().addUserInfo(_userCredential!.user!.uid, name, surname, email);
    return null;
  }

  Future<String?> login(String email, String password) async {
    try {
      _userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';

        case 'wrong-password':
          return 'Wrong password';

        case 'too-many-requests':
          return 'Too many request wait';
      }
      return "Unexpected error";
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();

  }
}
