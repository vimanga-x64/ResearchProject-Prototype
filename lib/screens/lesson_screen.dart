// screens/lesson_screen.dart
import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../widgets/progress_bar.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  LessonScreen({required this.lesson});

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _totalScore = 0;
  int _score = 0;
  bool _showResult = false;
  double _progress = 0.0;

  void _submitAnswer() {
    if (_selectedAnswerIndex == null) return;

    final currentQuestion = widget.lesson.questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswerIndex == currentQuestion.correctIndex;


      setState(() {
      _showResult = true;
      if (isCorrect) {
        _score += currentQuestion.points;  // Add question's points to total
      }
    });

   Future.delayed(Duration(seconds: 1), () {
    if (_currentQuestionIndex < widget.lesson.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _showResult = false;
      });
    } else {
      Navigator.pop(context, _score); // Return just this lesson's score
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final question = widget.lesson.questions[_currentQuestionIndex];
    

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('Score: $_totalScore', style: TextStyle(fontSize: 18))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProgressBar(progress: _progress),
            SizedBox(height: 20),
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 20),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return Card(
                color: _showResult
                    ? index == question.correctIndex
                        ? Colors.green.shade100
                        : _selectedAnswerIndex == index
                            ? Colors.red.shade100
                            : null
                    : null,
                child: ListTile(
                  title: Text(option),
                  onTap: _showResult ? null : () {
                    setState(() => _selectedAnswerIndex = index);
                  },
                ),
              );
            }).toList(),
            Spacer(),
            ElevatedButton(
              onPressed: _selectedAnswerIndex == null || _showResult 
                  ? null 
                  : _submitAnswer,
              child: Text(_currentQuestionIndex == widget.lesson.questions.length - 1
                  ? 'Finish'
                  : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}