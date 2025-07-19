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
        'highestStreak': user.highestStreak, 
        'createdAt': user.createdAt,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateUserData(String uid, {int? score, int? highestStreak}) async {
  try {
    final Map<String, dynamic> updateData = {
      'lastUpdated': FieldValue.serverTimestamp(),
    };
    
    if (score != null) {
      updateData['score'] = score;
    }
    
    if (highestStreak != null) {
      updateData['highestStreak'] = highestStreak;
    }

    await _firestore.collection('users').doc(uid).update(updateData);
  } catch (e) {
    print('Error updating user data: $e');
    rethrow; // Consider rethrowing or handling the error appropriately
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