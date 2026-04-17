import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    try {
      await _saveUserDoc(credential.user, name: credential.user?.displayName);
    } catch (error, stackTrace) {
      debugPrint('Firestore user upsert failed on sign-in: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return credential;
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null && name.trim().isNotEmpty) {
      await user.updateDisplayName(name.trim());
      await user.reload();
    }
    try {
      await _saveUserDoc(_auth.currentUser, name: name);
    } catch (error, stackTrace) {
      debugPrint('Firestore user upsert failed on sign-up: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _saveUserDoc(User? user, {String? name}) async {
    if (user == null) return;
    final now = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(user.uid).set(
      {
        'uid': user.uid,
        'email': user.email,
        'name': (name ?? user.displayName ?? '').trim(),
        'lastLoginAt': now,
        'updatedAt': now,
        'createdAt': now,
      },
      SetOptions(merge: true),
    );
  }
}
