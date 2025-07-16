// widgets/progress_bar.dart
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:hsluv/hsluv.dart';

enum ProgressBarStyle {
  smooth,
  stepped,
  celebratory,
}

class ProgressBar extends StatefulWidget {
  final double progress;
  final Color? color;
  final double height;
  final bool isCorrectAnswer;
  final int totalSteps;
  final int currentStep;
  final ProgressBarStyle style;
  final VoidCallback? onComplete;

  const ProgressBar({
    required this.progress,
    this.color,
    this.height = 8.0,
    this.isCorrectAnswer = false,
    this.totalSteps = 0,
    this.currentStep = 0,
    this.style = ProgressBarStyle.smooth,
    this.onComplete,
    Key? key,
  }) : super(key: key);

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Color?> _colorAnimation;
  double _displayedProgress = 0.0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && widget.progress >= 1.0 && widget.onComplete != null) {
          widget.onComplete!();
        }
      });

    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    // Clamp progress between 0.0 and 1.0
    final clampedProgress = widget.progress.clamp(0.0, 1.0).toDouble();

    _progressAnimation = Tween<double>(
      begin: _displayedProgress,
      end: clampedProgress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuint,
      ),
    )..addListener(() {
        setState(() {
          _displayedProgress = _progressAnimation.value.clamp(0.0, 1.0);
        });
      });

    // Simplified bounce animation that stays within bounds
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isCorrectAnswer) {
      _bounceAnimation = TweenSequence<double>([
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
          weight: 1.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
          weight: 1.0,
        ),
      ]).animate(_controller);
    }

    _colorAnimation = ColorTween(
      begin: widget.color ?? Colors.blue,
      end: Colors.green,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.progress != oldWidget.progress || 
        widget.isCorrectAnswer != oldWidget.isCorrectAnswer) {
      _setupAnimations();
      
      if (widget.isCorrectAnswer) {
        _controller
          ..reset()
          ..forward();
      } else {
        _controller.animateTo(1.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSmoothProgressBar() {
    final progressColor = widget.isCorrectAnswer 
        ? _colorAnimation.value ?? widget.color ?? Colors.blue
        : widget.color ?? Colors.blue;

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height / 2),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              color: Colors.grey[200],
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isCorrectAnswer ? _bounceAnimation.value : 1.0,
                child: Container(
                  width: MediaQuery.of(context).size.width * _displayedProgress,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    gradient: LinearGradient(
                      colors: [
                        HSLColor.fromColor(progressColor).withLightness(0.6).toColor(),
                        progressColor,
                      ],
                      stops: [0.3, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildSteppedProgressBar() {
    final theme = Theme.of(context);
    final progressColor = widget.color ?? theme.primaryColor;

    return Container(
      height: widget.height,
      child: Row(
        children: List.generate(widget.totalSteps, (index) {
          return Expanded(
            child: Container(
              height: widget.height,
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= widget.currentStep
                    ? progressColor
                    : theme.colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(widget.height / 2),
                boxShadow: index <= widget.currentStep
                    ? [
                        BoxShadow(
                          color: progressColor.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCelebratoryProgressBar() {
    return OpenContainer(
      closedBuilder: (_, openContainer) => _buildSmoothProgressBar(),
      openBuilder: (_, closeContainer) => _CelebrationScreen(
        onClose: closeContainer,
        score: (_displayedProgress * 100).round(),
      ),
      transitionDuration: Duration(milliseconds: 500),
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case ProgressBarStyle.stepped:
        return _buildSteppedProgressBar();
      case ProgressBarStyle.celebratory:
        return _buildCelebratoryProgressBar();
      case ProgressBarStyle.smooth:
      default:
        return _buildSmoothProgressBar();
    }
  }
}

class _CelebrationScreen extends StatelessWidget {
  final VoidCallback onClose;
  final int score;

  const _CelebrationScreen({
    required this.onClose,
    required this.score,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lesson Complete!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Score: $score%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: onClose,
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}