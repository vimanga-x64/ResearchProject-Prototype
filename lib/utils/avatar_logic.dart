// utils/avatar_logic.dart
String getAvatarEmotion(int score) {
  if (score >= 80) return "happy";
  if (score >= 50) return "neutral";
  return "sad";
}