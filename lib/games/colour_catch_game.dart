import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mini_mind_quest/helpers/adHelper.dart';
import 'package:mini_mind_quest/helpers/sound_manager.dart';

class ColourCatchGame extends StatefulWidget {
  final VoidCallback onCompleted;

  const ColourCatchGame({super.key, required this.onCompleted});

  @override
  State<ColourCatchGame> createState() => _ColourCatchGameState();
}

class _ColourCatchGameState extends State<ColourCatchGame> {
  final List<Color> _colors = [
    Colors.red, // Primary
    Colors.blue, // Primary
    Colors.yellow, // Primary
    Colors.green, // Secondary
    Colors.orange, // Secondary
    Colors.purple, // Secondary
  ];

  late Color _targetColor;
  late List<Color> _options;
  int _score = 0;
  String _message = 'Tap the matching color!';
  static const int _winScore = 10;

  late ConfettiController _confettiController;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    AdHelper().showInterstitialAd();
    _resetGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _nextRound();
    });
  }

  void _nextRound() {
    _targetColor = _colors[Random().nextInt(_colors.length)];

    final List<Color> pool = List.from(_colors)..remove(_targetColor);
    pool.shuffle();

    _options = pool.take(8).toList();
    _options.insert(Random().nextInt(9), _targetColor);

    _message = 'Tap the ${_colorName(_targetColor)} box!';
  }

  void _onColorTapped(Color color) {
    SoundManager.playTap();

    if (color == _targetColor) {
      SoundManager.playCorrect();
      setState(() {
        _score++;
        _message = '✔️ Good job!';
      });
    } else {
      SoundManager.playWrong();
      setState(() {
        _score--;
        _message = '❌ Try again!';
      });
    }

    if (_score >= _winScore) {
      _confettiController.play();
      setState(() => _message = '🎉 You Win!');
      Future.delayed(const Duration(seconds: 2), () {
        _interstitialAd?.show();
        widget.onCompleted();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _nextRound());
      });
    }
  }

  String _colorName(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.green) return 'green';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.purple) return 'purple';
    return 'color';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightBlueAccent,
                Colors.yellowAccent,
                Colors.orangeAccent,
                Colors.pinkAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  SoundManager.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => setState(() {}),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _message,
                  key: ValueKey<String>(_message),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 300,
                height: 300,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final color = _options[index];
                    return GestureDetector(
                      onTap: () => _onColorTapped(color),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Score: $_score',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: _colors,
          ),
        ),
      ],
    );
  }
}
