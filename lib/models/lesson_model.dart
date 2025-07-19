// models/lesson_model.dart
class Question {
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final int points;
  final String? imageUrl;  
  final String? explanation;  

  Question({
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.imageUrl,  
    this.explanation, 
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
            //explanation: 'The sum of 2 and 2 is 4.',
          ),
          Question(
            questionText: 'What is 5 × 3?',
            options: ['10', '15', '20', '25'],
            correctIndex: 1,
          ),
          Question(
            questionText: 'What is the value of π (pi) rounded to two decimal places?',
            options: ['3.14', '3.16', '3.18', '3.12'],
            correctIndex: 0,
            explanation: 'π is approximately 3.14159, which rounds to 3.14.',
            points: 15,
        ),
        Question(
            questionText: 'Solve for x: 2x + 5 = 15',
            options: ['5', '10', '7.5', '20'],
            correctIndex: 0,
            explanation: 'Subtract 5 from both sides: 2x = 10. Divide by 2: x = 5.',
            points: 20,
          ),
          Question(
            questionText: 'What is the area of a rectangle with length 8 and width 5?',
            options: ['13', '40', '26', '35'],
            correctIndex: 1,
            explanation: 'Area = length × width = 8 × 5 = 40.',
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
          Question(
          questionText: 'Which planet is known as the Red Planet?',
          options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
          correctIndex: 1,
          explanation: 'Mars appears red due to iron oxide (rust) on its surface.',
          points: 15,
        ),
          Question(
            questionText: 'What is the chemical symbol for gold?',
            options: ['Au', 'Ag', 'Pb', 'Fe'],
            correctIndex: 0,
          ),
          Question(
            questionText: 'What is the powerhouse of the cell?',
            options: ['Nucleus', 'Ribosome', 'Mitochondria', 'Endoplasmic Reticulum'],
            correctIndex: 2,
            explanation: 'Mitochondria are known as the powerhouse because they produce energy.',
          ),

          Question(
              questionText: 'Which gas do plants absorb during photosynthesis?',
              options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
              correctIndex: 2,
              explanation: 'Plants convert CO₂ and sunlight into glucose and oxygen.',
              points: 20,
            ),
        ];
        break;
      case 'history':
        questions = [
          Question(
            questionText: 'Who was the first President of the United States?',
            options: ['George Washington', 'Thomas Jefferson', 'Abraham Lincoln', 'John Adams'],
            correctIndex: 0,
          ),
          Question(
            questionText: 'What year did World War II end?',
            options: ['1945', '1939', '1950', '1941'],
            correctIndex: 0,
            explanation: 'World War II ended in 1945 with the surrender of Germany and Japan.',
            points: 15,
          ),
          Question(
            questionText: 'Who wrote the Declaration of Independence?',
            options: ['George Washington', 'Benjamin Franklin', 'Thomas Jefferson', 'John Hancock'],
            correctIndex: 2,
          ),
          Question(
            questionText: 'What ancient civilization built the pyramids?',
            options: ['Romans', 'Greeks', 'Egyptians', 'Mayans'],
            correctIndex: 2,
          ),
          Question(
              questionText: 'Which event started the American Civil War?',
              options: ['Boston Tea Party', 'Attack on Fort Sumter', 'Signing of the Constitution', 'Battle of Gettysburg'],
              correctIndex: 1,
              explanation: 'The attack on Fort Sumter in 1861 marked the start of the Civil War.',
              points: 20,
            ),
        ];
        break;
        case 'english':
        questions = [
          Question(
            questionText: 'What is the synonym of "happy"?',
            options: ['Sad', 'Joyful', 'Angry', 'Bored'],
            correctIndex: 1,
          ),
          Question(
            questionText: 'What is the antonym of "difficult"?',
            options: ['Easy', 'Hard', 'Complex', 'Complicated'],
            correctIndex: 0,
            explanation: 'The opposite of difficult is easy.',
            points: 15,
          ),
          Question(
            questionText: 'Which word is a noun?',
            options: ['Run', 'Quickly', 'Happiness', 'Beautiful'],
            correctIndex: 2,
          ),
          Question(
            questionText: 'What is the past tense of "go"?',
            options: ['Goes', 'Gone', 'Went', 'Going'],
            correctIndex: 2,
          ),
          Question(
              questionText: 'What is the main idea of a story?',
              options: ['The setting', 'The plot twist', 'The central theme', 'The characters'],
              correctIndex: 2,
              explanation: 'The main idea is the central theme or message of the story.',
              points: 20,
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