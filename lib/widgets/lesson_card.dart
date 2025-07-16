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
  bool _isCurrentAnswerCorrect = false; // Added to track if current answer is correct for ProgressBar

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
    _isCurrentAnswerCorrect = _selectedAnswerIndex == currentQuestion.correctIndex; // Set this flag

    setState(() {
      _showResult = true; // Show results immediately upon submission
      if (_isCurrentAnswerCorrect) {
        _totalScore += currentQuestion.points;
      } else {
        // Deduct 10 points for a wrong answer, ensuring score doesn't go below 0
        _totalScore = (_totalScore - 10).clamp(0, double.infinity).toInt();
      }
    });

    // We removed the Future.delayed here because the buttons will now handle navigation.
    // The result should be shown immediately after submission.
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < widget.lesson.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _showResult = false; // Hide result view for the next question
        _updateProgress(); // Update progress for the new question
      });
    } else {
      // If it's the last question, pop the screen with the final score
      Navigator.pop(context, _totalScore);
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
      body: Column(
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
                  // Pass the correctness of the *current* submitted answer to ProgressBar
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
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        question.questionText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: question.options.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final isCorrectOption = index == question.correctIndex;
                        final isSelectedOption = index == _selectedAnswerIndex;
                        final showColors = _showResult; // Only show colors after submission

                        Color? cardColor;
                        Color? borderColor;
                        Widget? suffixIcon;
                        Color? circleColor;
                        Widget? circleChild;

                        if (showColors) {
                          if (isCorrectOption) {
                            cardColor = Colors.green.shade50;
                            borderColor = Colors.green;
                            suffixIcon = Icon(Icons.check, color: Colors.green);
                            circleColor = Colors.green;
                            circleChild = Icon(Icons.check, size: 16, color: Colors.white);
                          } else if (isSelectedOption && !isCorrectOption) {
                            cardColor = Colors.red.shade50;
                            borderColor = Colors.red;
                            suffixIcon = Icon(Icons.close, color: Colors.red);
                            circleColor = Colors.red;
                            circleChild = Icon(Icons.close, size: 16, color: Colors.white);
                          } else {
                            borderColor = Colors.grey.shade200;
                            circleColor = Colors.grey.shade200;
                          }
                        } else {
                          // Before submission
                          if (isSelectedOption) {
                            borderColor = Colors.blue.shade400;
                            circleColor = Colors.blue.shade100;
                          } else {
                            borderColor = Colors.grey.shade200;
                            circleColor = Colors.grey.shade200;
                          }
                        }

                        return Card(
                          elevation: 2,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: borderColor ?? Colors.grey.shade200, // Default if null
                              width: 1.5,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _showResult ? null : () {
                              setState(() => _selectedAnswerIndex = index);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: circleColor,
                                    ),
                                    child: circleChild,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      question.options[index],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  if (showColors && isCorrectOption)
                                    Text(
                                      '+${question.points} pts',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  // Display -10 pts for incorrect selected answer
                                  if (showColors && isSelectedOption && !isCorrectOption)
                                    Text(
                                      '-10 pts', // Display deduction for incorrect answers
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Buttons for Submit/Next Question/Skip
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
                              onPressed: _moveToNextQuestion, // Allow skipping directly to next question
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
                                  color: Colors.black,
                                ),
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
    );
  }
}