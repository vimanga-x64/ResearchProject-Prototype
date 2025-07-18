// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'score': user.score,
        'createdAt': user.createdAt,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateUserScore(String uid, int score) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'score': score,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e.toString());
    }
  }
}