// models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int lastScore;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.lastScore,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
    uid: data['uid'],
    email: data['email'],
    displayName: data['displayName'],
    photoUrl: data['photoUrl'],
    lastScore: data['lastScore'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'lastScore': lastScore,
  };
}