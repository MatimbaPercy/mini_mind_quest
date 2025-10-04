import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mini_mind_quest/helpers/sound_manager.dart';

class MathPuzzlesGame extends StatefulWidget {
  final VoidCallback onCompleted;

  const MathPuzzlesGame({super.key, required this.onCompleted});

  @override
  State<MathPuzzlesGame> createState() => _MathPuzzlesGameState();
}

class _MathPuzzlesGameState extends State<MathPuzzlesGame> {
  int _score = 0;
  final int _winScore = 5;

  late int _num1;
  late int _num2;
  late int _correctAnswer;
  late List<int> _options;

  Color? _feedbackColor;

  late ConfettiController _confettiController;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _generateProblem();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _generateProblem() {
    final random = Random();
    _num1 = random.nextInt(10) + 1;
    _num2 = random.nextInt(10) + 1;
    _correctAnswer = _num1 + _num2;

    final Set<int> tempOptions = {_correctAnswer};
    while (tempOptions.length < 4) {
      int wrongOption = _correctAnswer + random.nextInt(5) - 2;
      if (wrongOption != _correctAnswer && wrongOption > 0) {
        tempOptions.add(wrongOption);
      }
    }
    _options = tempOptions.toList()..shuffle();
  }

  void _onAnswerTapped(int selectedAnswer) async {
    if (_feedbackColor != null) return;

    // play tap sound on press
    SoundManager.playTap();

    if (selectedAnswer == _correctAnswer) {
      // correct answer
      SoundManager.playCorrect();

      setState(() {
        _score++;
        _feedbackColor = Colors.green;
      });

      if (_score >= _winScore) {
        // play victory sound + confetti
        _confettiController.play();

        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) widget.onCompleted();
      } else {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _generateProblem();
              _feedbackColor = null;
            });
          }
        });
      }
    } else {
      // wrong answer
      SoundManager.playWrong();

      setState(() {
        _feedbackColor = Colors.red;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _feedbackColor = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pinkAccent,
                Colors.orangeAccent,
                Colors.yellowAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("⭐", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    'Score: $_score / $_winScore',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("🎉", style: TextStyle(fontSize: 32)),
                ],
              ),
              const SizedBox(height: 40),

              // Math Problem Box
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _feedbackColor ?? Colors.transparent,
                    width: 5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: Text(
                  '$_num1 🍎 + $_num2 🍌 = ?',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Answer Buttons
              ..._options.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor:
                            Colors
                                .primaries[option % Colors.primaries.length]
                                .shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () => _onAnswerTapped(option),
                      child: Text(
                        option.toString(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
            ],
          ),
        ),
      ],
    );
  }
}
