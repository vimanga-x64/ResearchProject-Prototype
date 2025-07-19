// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int score;
  final int highestStreak; // Add this line
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.score,
    this.highestStreak = 0, // Initialize to 0
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      score: map['score'] ?? 0,
      highestStreak: map['highestStreak'] ?? 0, // Add this line
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'score': score,
      'highestStreak': highestStreak, // Add this line
      'createdAt': createdAt,
    };
  }
}