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
    final isCorrect = _selectedAnswerIndex == currentQuestion.correctIndex;

    setState(() {
      _showResult = true;
      if (isCorrect) {
        _totalScore += currentQuestion.points;
      }
    });

    Future.delayed(Duration(seconds: 1), () {
      if (_currentQuestionIndex < widget.lesson.questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswerIndex = null;
          _showResult = false;
          _updateProgress();
        });
      } else {
        Navigator.pop(context, _totalScore);
      }
    });
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
                        final isCorrect = index == question.correctIndex;
                        final isSelected = index == _selectedAnswerIndex;
                        final showResults = _showResult && (isSelected || isCorrect);

                        return Card(
                          elevation: 2,
                          color: showResults
                              ? isCorrect
                                  ? Colors.green.shade50
                                  : Colors.red.shade50
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue.shade400
                                  : Colors.grey.shade200,
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
                                      color: showResults
                                          ? isCorrect
                                              ? Colors.green
                                              : Colors.red
                                          : isSelected
                                              ? Colors.blue.shade100
                                              : Colors.grey.shade200,
                                    ),
                                    child: showResults
                                        ? Icon(
                                            isCorrect ? Icons.check : Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      question.options[index],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  if (showResults && isCorrect)
                                    Text(
                                      '+${question.points} pts',
                                      style: TextStyle(
                                        color: Colors.green,
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
                  ElevatedButton(
                    onPressed: _selectedAnswerIndex == null || _showResult
                        ? null
                        : _submitAnswer,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}