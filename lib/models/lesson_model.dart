// models/lesson_model.dart
class Question {
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final int points;

  Question({
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.points = 10, // Default points for each question
  });
}

class Lesson {
  final String id;
  final String title;
  final List<Question> questions;

  Lesson({
    required this.id,
    required this.title,
    required this.questions,
  });

  // Add a factory method to create sample lessons
  factory Lesson.createSampleLesson(String subject) {
    List<Question> questions = [];
    
    switch (subject.toLowerCase()) {
      case 'math':
        questions = [
          Question(
            questionText: 'What is 2 + 2?',
            options: ['3', '4', '5', '6'],
            correctIndex: 1,
          ),
          Question(
            questionText: 'What is 5 × 3?',
            options: ['10', '15', '20', '25'],
            correctIndex: 1,
          ),
        ];
        break;
      case 'science':
        questions = [
          Question(
            questionText: 'What is H₂O?',
            options: ['Gold', 'Water', 'Salt', 'Oxygen'],
            correctIndex: 1,
          ),
        ];
        break;
      // Add more subjects as needed
      default:
        questions = [
          Question(
            questionText: 'Sample question for $subject?',
            options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
            correctIndex: 0,
          ),
        ];
    }

    return Lesson(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: subject,
      questions: questions,
    );
  }
}