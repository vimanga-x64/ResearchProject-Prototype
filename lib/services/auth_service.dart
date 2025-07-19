// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_prototype/services/firestore_service.dart';
import 'package:app_prototype/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Email login
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Facebook Sign-In
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = 
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
        
        UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Microsoft Sign-In
  Future<User?> signInWithMicrosoft() async {
    try {
      final oauthProvider = OAuthProvider('microsoft.com');
      oauthProvider.setScopes(['openid', 'email', 'profile']);
      UserCredential result = await _auth.signInWithProvider(oauthProvider);
      return result.user;
    } catch (e) {
      print('Microsoft login error: $e');
      return null;
    }
  } 

  Future<User?> register(String email, String password, String name) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user with initial score of 75 and streak 0
      await _firestoreService.createUser(UserModel(
        uid: authResult.user!.uid,
        email: email,
        displayName: name,
        score: 75,
        highestStreak: 0, // Initialize to 0
        createdAt: DateTime.now(),
      ));

      await authResult.user?.updateProfile(displayName: name);
      await authResult.user?.reload();

      return authResult.user;
    } catch (e) {
      print("Registration error: $e");
      return null;
    }
  }

  // Get current user's data including score
  Future<UserModel?> getCurrentUserData() async {
    if (_auth.currentUser == null) return null;
    return await _firestoreService.getUser(_auth.currentUser!.uid);
  }

  // Update user score in Firestore
  Future<void> updateUserScore(int score) async {
    if (_auth.currentUser == null) return;
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'score': score,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Sign out with score saving
  Future<void> signOut() async {
    await _auth.signOut();
  }
}