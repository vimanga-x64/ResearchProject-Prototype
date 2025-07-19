// screens/lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/lesson_model.dart';
import '../widgets/progress_bar.dart';
import '../widgets/avatar_widget.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';

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
  bool _showFeedbackAnimation = false;
  late ConfettiController _confettiController;

@override
void initState() {
  super.initState();
  _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  _updateProgress();
}

@override
void dispose() {
  _confettiController.dispose();
  super.dispose();
}


  void _updateProgress() {
    setState(() {
      _progress = (_currentQuestionIndex + 1) / widget.lesson.questions.length;
    });
  }

void _submitAnswer() async {
  if (_selectedAnswerIndex == null) return;

  final currentQuestion = widget.lesson.questions[_currentQuestionIndex];
  _isCurrentAnswerCorrect = _selectedAnswerIndex == currentQuestion.correctIndex;



  setState(() {
    _showResult = true;
    _showFeedbackAnimation = true;
    if (_isCurrentAnswerCorrect) {
      _totalScore += currentQuestion.points;
      _confettiController.play();
    } else {
      _totalScore = (_totalScore - 10).clamp(0, double.infinity).toInt();
    }
  });

  await Future.delayed(Duration(milliseconds: 1500));
  if (mounted) {
    setState(() => _showFeedbackAnimation = false);
  }
}

  void _moveToNextQuestion() {
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
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.lesson.questions[_currentQuestionIndex];
    final questionNumber = _currentQuestionIndex + 1;
    final totalQuestions = widget.lesson.questions.length;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.lesson.title),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Avatar/Feedback Circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: _showFeedbackAnimation
                            ? _isCurrentAnswerCorrect
                                ? Colors.green.shade300
                                : Colors.red.shade300
                            : Colors.blue.shade200,
                        width: 3,
                      ),
                    ),
                    child: _showFeedbackAnimation
                        ? ClipOval(
                            child: Lottie.asset(
                              _isCurrentAnswerCorrect
                                  ? 'assets/animations/success.json'
                                  : 'assets/animations/error.json',
                              width: 120,
                              height: 120,
                              repeat: false,
                              fit: BoxFit.cover,
                            ),
                          )
                        : AvatarWidget(
                            emotion: "neutral", // Always show neutral avatar
                            size: 110,
                          ),
                  ),
                  SizedBox(height: 20),

                  // Progress and Question Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question $questionNumber/$totalQuestions',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
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
                  SizedBox(height: 20),

                  // Question Card
                  Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Question $questionNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${question.points} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (question.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    question.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16),
              ],
              Text(
                question.questionText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    ),
                  SizedBox(height: 20),

                  Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isCorrect = index == question.correctIndex;
        final isSelected = index == _selectedAnswerIndex;
        //final showExplanation = _showResult && isSelected && !isCorrect;
        
        Color? cardColor;
        Color? borderColor;
        IconData? icon;
        Color? iconColor;
        String? pointsText;

        if (_showResult) {
          if (isCorrect) {
            cardColor = Colors.green.shade50;
            borderColor = Colors.green;
            icon = Icons.check;
            iconColor = Colors.green;
            pointsText = '+${question.points} pts';
          } else if (isSelected) {
            cardColor = Colors.red.shade50;
            borderColor = Colors.red;
            icon = Icons.close;
            iconColor = Colors.red;
            pointsText = '-10 pts';
          }
        }

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 2,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: borderColor ?? 
                  (isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300),
              width: isSelected ? 2 : 1.5,
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
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Colors.grey.shade200,
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          color: isSelected 
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: Text(option)),
                  if (pointsText != null) 
                    Text(
                      pointsText,
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (icon != null) ...[
                    SizedBox(width: 8),
                    Icon(icon, color: iconColor),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ),
                  // Explanation Section
                  if (_showResult && question.explanation != null)
                    Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explanation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(question.explanation!),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 20),

                  // Buttons
                  if (_showResult)
                    ElevatedButton(
                      onPressed: _moveToNextQuestion,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue.shade600,
                      ),
                      child: Text(
                        _currentQuestionIndex == widget.lesson.questions.length - 1
                            ? 'Finish Lesson'
                            : 'Next Question',
                        style: TextStyle(fontSize: 18),
                      ),
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
                            child: Text('Submit', style: TextStyle(fontSize: 18)),
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
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green, Colors.blue,
              Colors.pink, Colors.orange, Colors.purple
            ],
          ),
        ),
      ],
    );
  }
}