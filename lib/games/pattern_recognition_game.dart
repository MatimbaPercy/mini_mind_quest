import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PatternRecognitionGame extends StatefulWidget {
  final VoidCallback onCompleted;

  const PatternRecognitionGame({super.key, required this.onCompleted});

  @override
  State<PatternRecognitionGame> createState() => _PatternRecognitionGameState();
}

class _PatternRecognitionGameState extends State<PatternRecognitionGame> {
  int _score = 0;
  final int _winScore = 5;
  final int _gridSize = 9;

  late IconData _commonIcon;
  late IconData _oddIcon;
  late int _oddIconIndex;
  late List<IconData> _gridItems;

  bool _isProcessing = false;
  late ConfettiController _confettiController;
  InterstitialAd? _interstitialAd;

  final List<IconData> _iconPool = [
    Icons.star,
    Icons.favorite,
    Icons.anchor,
    Icons.bug_report,
    Icons.lightbulb,
    Icons.local_florist,
    Icons.pets,
    Icons.wb_sunny,
    Icons.ac_unit,
    Icons.cloud,
    Icons.extension,
    Icons.face,
    Icons.cake,
    Icons.directions_bike,
    Icons.emoji_emotions,
    Icons.rocket_launch,
    Icons.shield,
    Icons.sports_esports,
    Icons.camera_alt,
    Icons.music_note,
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
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
    _iconPool.shuffle();
    _commonIcon = _iconPool[0];
    _oddIcon = _iconPool[1];
    _oddIconIndex = random.nextInt(_gridSize);

    _gridItems = List.generate(_gridSize, (index) {
      return index == _oddIconIndex ? _oddIcon : _commonIcon;
    });

    setState(() {
      _isProcessing = false;
    });
  }

  void _onIconTapped(int index) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    if (index == _oddIconIndex) {
      setState(() => _score++);

      if (_score >= _winScore) {
        _confettiController.play();
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) widget.onCompleted();
      } else {
        Future.delayed(const Duration(milliseconds: 500), _generateProblem);
      }
    } else {
      Future.delayed(const Duration(milliseconds: 500), _generateProblem);
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
                Colors.orangeAccent,
                Colors.yellowAccent,
                Colors.pinkAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Find the odd one out!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Score: $_score / $_winScore',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _gridSize,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onIconTapped(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors
                                  .primaries[index % Colors.primaries.length]
                                  .shade300,
                              Colors
                                  .primaries[index % Colors.primaries.length]
                                  .shade500,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _gridItems[index],
                            size: 50,
                            color: Colors.white,
                          ),
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
          alignment: Alignment.topCenter,
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
            ],
          ),
        ),
      ],
    );
  }
}
