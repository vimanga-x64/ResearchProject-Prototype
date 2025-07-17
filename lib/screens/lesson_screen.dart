// screens/lesson_screen.dart
import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../widgets/progress_bar.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({required this.lesson, Key? key}) : super(key: key);

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _totalScore = 0;
  bool _showResult = false;
  double _progress = 0.0;
  bool _isCurrentAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    _updateProgress();
  }

  void _updateProgress() {
    setState(() {
      _progress = (_currentQuestionIndex + 1) / widget.lesson.questions.length;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswerIndex == null) return;

    final currentQuestion = widget.lesson.questions[_currentQuestionIndex];
    _isCurrentAnswerCorrect = _selectedAnswerIndex == currentQuestion.correctIndex;

    setState(() {
      _showResult = true;
      if (_isCurrentAnswerCorrect) {
        _totalScore += currentQuestion.points;
      } else {
         _totalScore -= currentQuestion.points;
      }
    });
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < widget.lesson.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _showResult = false;
        _updateProgress(); // Update progress when moving to next question
      });
    } else {
      Navigator.pop(context, _totalScore); // Return the total score
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.lesson.questions[_currentQuestionIndex];
    final questionNumber = _currentQuestionIndex + 1;
    final totalQuestions = widget.lesson.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // Make app bar transparent
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Chip(
                label: Text(
                  '$_totalScore pts',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue.shade600,
              ),
            ),
          ),
        ],
      ),
      body: Stack( // Use Stack to layer the background and content
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/lesson_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          SafeArea( // Wrap the existing Column with SafeArea
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question $questionNumber/$totalQuestions',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${(_progress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ProgressBar(
                        progress: _progress,
                        height: 10,
                        color: Colors.blue,
                        isCorrectAnswer: _showResult && _isCurrentAnswerCorrect,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                        if (_showResult)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _moveToNextQuestion,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _currentQuestionIndex == widget.lesson.questions.length - 1
                                        ? 'Finish Lesson'
                                        : 'Next Question',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _selectedAnswerIndex == null ? null : _submitAnswer,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.blue.shade600,
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              if (_selectedAnswerIndex != null) SizedBox(width: 10),
                              if (_selectedAnswerIndex != null)
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _moveToNextQuestion,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Colors.grey.shade300,
                                    ),
                                    child: Text(
                                      'Skip',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}