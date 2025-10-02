import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MemoryMatchGame extends StatefulWidget {
  final VoidCallback onCompleted;

  const MemoryMatchGame({super.key, required this.onCompleted});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame>
    with SingleTickerProviderStateMixin {
  late List<GameCard> _cards;
  GameCard? _flippedCard1;
  GameCard? _flippedCard2;
  bool _isChecking = false;

  late ConfettiController _confettiController;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _setupGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _setupGame() {
    final emojis = ["⭐", "❤️", "🐶", "🐱", "🌸", "☀️", "🍎", "🍌"];
    _cards =
        [...emojis, ...emojis]
            .asMap()
            .entries
            .map((entry) => GameCard(id: entry.key, emoji: entry.value))
            .toList();
    _cards.shuffle();
    _flippedCard1 = null;
    _flippedCard2 = null;
    _isChecking = false;
  }

  void _onCardTapped(GameCard card) {
    if (_isChecking || card.isMatched || card.isFlipped) return;

    setState(() {
      card.isFlipped = true;
      if (_flippedCard1 == null) {
        _flippedCard1 = card;
      } else {
        _flippedCard2 = card;
        _isChecking = true;
        _checkForMatch();
      }
    });
  }

  void _checkForMatch() async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (_flippedCard1!.emoji == _flippedCard2!.emoji) {
      setState(() {
        _flippedCard1!.isMatched = true;
        _flippedCard2!.isMatched = true;
      });
    } else {
      setState(() {
        _flippedCard1!.isFlipped = false;
        _flippedCard2!.isFlipped = false;
      });
    }

    setState(() {
      _flippedCard1 = null;
      _flippedCard2 = null;
      _isChecking = false;
    });

    if (_cards.every((c) => c.isMatched)) {
      _confettiController.play();
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) widget.onCompleted();
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
        Center(
          child: GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              final card = _cards[index];
              return GestureDetector(
                onTap: () => _onCardTapped(card),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color:
                        card.isFlipped
                            ? Colors.white
                            : Colors
                                .primaries[index % Colors.primaries.length]
                                .shade400,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                    border:
                        card.isMatched
                            ? Border.all(color: Colors.greenAccent, width: 4)
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      card.isFlipped ? card.emoji : "❓",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: card.isMatched ? Colors.green : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
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

class GameCard {
  final int id;
  final String emoji;
  bool isFlipped = false;
  bool isMatched = false;

  GameCard({required this.id, required this.emoji});
}
