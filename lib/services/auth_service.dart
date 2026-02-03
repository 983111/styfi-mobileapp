import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final ValueNotifier<UserRole?> roleNotifier = ValueNotifier(null);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Initialize and listen to user role
  void init() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _db.collection('users').doc(user.uid).snapshots().listen((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final appUser = AppUser.fromMap(snapshot.data()!, snapshot.id);
            roleNotifier.value = appUser.role;
          } else {
            // User exists in Auth but not in DB yet (needs to select role)
            roleNotifier.value = null; 
          }
        });
      } else {
        roleNotifier.value = null;
      }
    });
  }

  // Called when user selects "Buyer" or "Seller" on the selection screen
  Future<void> setUserRole(UserRole role) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': role == UserRole.seller ? 'seller' : 'buyer',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      roleNotifier.value = role;
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // We do NOT create the user doc here. We wait for them to pick a role.
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    roleNotifier.value = null;
  }
}
