// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_prototype/services/firestore_service.dart'; // Import FirestoreService
import 'package:app_prototype/models/user_model.dart'; // Import UserModel

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Microsoft Sign-In (Requires additional setup in Firebase)
  Future<User?> signInWithMicrosoft() async {
  try {
    // Create a new provider
    final oauthProvider = OAuthProvider('microsoft.com');
    
    // Set scopes if needed
    oauthProvider.setScopes([
      'openid',
      'email',
      'profile',
    ]);
    
    // Sign in
    UserCredential result = await _auth.signInWithProvider(oauthProvider);
    return result.user;
  } catch (e) {
    print('Microsoft login error: $e');
    return null;
   }
 } 

  Future<User?> register(String email, String password, String name) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save user data to Firestore
      await _firestore.collection('users').doc(authResult.user!.uid).set({
        'uid': authResult.user!.uid,
        'email': email,
        'displayName': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Update display name in Auth (optional)
      await authResult.user?.updateProfile(displayName: name);
      await authResult.user?.reload();

      return authResult.user;
    } catch (e) {
      print("Registration error: $e");
      return null;
    }
  }

  // Get current user's data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc.data() as Map<String, dynamic>?;
  }


  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  
}