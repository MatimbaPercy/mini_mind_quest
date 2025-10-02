import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ColorSequenceGame extends StatefulWidget {
  final VoidCallback onCompleted;

  const ColorSequenceGame({super.key, required this.onCompleted});

  @override
  State<ColorSequenceGame> createState() => _ColorSequenceGameState();
}

class _ColorSequenceGameState extends State<ColorSequenceGame> {
  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.amber,
  ];

  final List<Color> _sequence = [];
  final List<Color> _playerSequence = [];
  int _level = 0;
  bool _isPlayerTurn = false;
  Color? _litColor;
  String _message = 'Watch the sequence...';
  static const int _winLevel = 5;

  late ConfettiController _confettiController;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _nextLevel();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _sequence.clear();
      _playerSequence.clear();
      _level = 0;
      _message = 'Watch the sequence...';
      _isPlayerTurn = false;
    });
    _nextLevel();
  }

  void _nextLevel() {
    setState(() {
      _level++;
      _playerSequence.clear();
      _isPlayerTurn = false;
      _message = 'Level $_level';
    });

    _sequence.add(_colors[Random().nextInt(_colors.length)]);
    _showSequence();
  }

  Future<void> _showSequence() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    for (final color in _sequence) {
      if (!mounted) return;
      setState(() => _litColor = color);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _litColor = null);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (!mounted) return;
    setState(() {
      _isPlayerTurn = true;
      _message = 'Your turn!';
    });
  }

  void _onColorTapped(Color color) {
    if (!_isPlayerTurn) return;

    _playerSequence.add(color);
    int currentIndex = _playerSequence.length - 1;

    if (_playerSequence[currentIndex] != _sequence[currentIndex]) {
      if (!mounted) return;
      setState(() => _message = 'Oops! Try again.');
      _isPlayerTurn = false;
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _resetGame();
      });
      return;
    }

    if (_playerSequence.length == _sequence.length) {
      _isPlayerTurn = false;
      if (_level >= _winLevel) {
        _confettiController.play();
        setState(() => _message = 'You Win!');
        Future.delayed(const Duration(milliseconds: 1500), () async {

          if (mounted) widget.onCompleted();
        });
      } else {
        setState(() => _message = 'Correct!');
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) _nextLevel();
        });
      }
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
                Colors.lightBlueAccent,
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
                width: 350,
                height: 350,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    return GestureDetector(
                      onTap: () => _onColorTapped(color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              _litColor == color
                                  ? Border.all(color: Colors.white, width: 6)
                                  : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                _litColor == color ? 0.6 : 0.3,
                              ),
                              spreadRadius: _litColor == color ? 6 : 3,
                              blurRadius: _litColor == color ? 12 : 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
