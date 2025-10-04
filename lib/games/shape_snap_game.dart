import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mini_mind_quest/helpers/adHelper.dart';
import 'package:mini_mind_quest/helpers/sound_manager.dart';

enum ShapeType { circle, square, triangle, star, heart, hexagon }

class ShapeSnapGame extends StatefulWidget {
  final VoidCallback onCompleted;

  const ShapeSnapGame({super.key, required this.onCompleted});

  @override
  State<ShapeSnapGame> createState() => _ShapeSnapGameState();
}

class _ShapeSnapGameState extends State<ShapeSnapGame> {
  final List<ShapeType> _shapes = ShapeType.values;
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  late ShapeType _targetShape;
  late Color _targetColor;
  late List<Map<String, dynamic>> _options; // shape + color
  int _score = 0;
  String _message = 'Tap the matching shape and color!';
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
    final random = Random();
    _targetShape = _shapes[random.nextInt(_shapes.length)];
    _targetColor = _colors[random.nextInt(_colors.length)];

    // Generate distractors ensuring they are unique and not the target
    final Set<String> usedKeys = {};
    final List<Map<String, dynamic>> distractors = [];

    while (distractors.length < 15) {
      ShapeType shape = _shapes[random.nextInt(_shapes.length)];
      Color color = _colors[random.nextInt(_colors.length)];
      String key = '${shape.index}-${color.value}';
      String targetKey = '${_targetShape.index}-${_targetColor.value}';
      if (key != targetKey && !usedKeys.contains(key)) {
        distractors.add({'shape': shape, 'color': color});
        usedKeys.add(key);
      }
    }

    // Insert the target in a random position in the final options list
    _options = List.from(distractors);
    _options.insert(random.nextInt(_options.length + 1), {
      'shape': _targetShape,
      'color': _targetColor,
    });

    _message =
        'Tap the ${_shapeName(_targetShape)} in ${_colorName(_targetColor)}!';
  }

  void _onShapeTapped(Map<String, dynamic> option) {
    SoundManager.playTap();

    if (option['shape'] == _targetShape && option['color'] == _targetColor) {
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

  String _shapeName(ShapeType shape) {
    switch (shape) {
      case ShapeType.circle:
        return 'circle';
      case ShapeType.square:
        return 'square';
      case ShapeType.triangle:
        return 'triangle';
      case ShapeType.star:
        return 'star';
      case ShapeType.heart:
        return 'heart';
      case ShapeType.hexagon:
        return 'hexagon';
    }
  }

  String _colorName(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.yellow) return 'yellow';
    return 'color';
  }

  Widget _buildShape(ShapeType shape, Color color) {
    switch (shape) {
      case ShapeType.circle:
        return Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        );
      case ShapeType.square:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ShapeType.triangle:
        return CustomPaint(painter: _TrianglePainter(color));
      case ShapeType.star:
        return CustomPaint(painter: _StarPainter(color));
      case ShapeType.heart:
        return CustomPaint(painter: _HeartPainter(color));
      case ShapeType.hexagon:
        return CustomPaint(painter: _HexagonPainter(color));
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
              IconButton(
                icon: Icon(
                  SoundManager.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => setState(() {}),
              ),
              const SizedBox(height: 20),
              Text(
                _message,
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
              const SizedBox(height: 20),
              Text(
                'Question:',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 80,
                height: 80,
                child: _buildShape(_targetShape, _targetColor),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 320,
                height: 320,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    return GestureDetector(
                      onTap: () => _onShapeTapped(option),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildShape(option['shape'], option['color']),
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
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.yellow,
              Colors.green,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }
}

// 🎨 Custom Shape Painters

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path =
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    for (int i = 0; i < 5; i++) {
      double angle = pi / 2 + i * 2 * pi / 5;
      double x = cx + r * cos(angle);
      double y = cy - r * sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);

      double innerAngle = angle + pi / 5;
      double innerR = r / 2.5;
      path.lineTo(cx + innerR * cos(innerAngle), cy - innerR * sin(innerAngle));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HeartPainter extends CustomPainter {
  final Color color;
  _HeartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path =
        Path()
          ..moveTo(size.width / 2, size.height * 0.75)
          ..cubicTo(
            -size.width * 0.25,
            size.height * 0.25,
            size.width * 0.25,
            -size.height * 0.25,
            size.width / 2,
            size.height * 0.25,
          )
          ..cubicTo(
            size.width * 0.75,
            -size.height * 0.25,
            size.width * 1.25,
            size.height * 0.25,
            size.width / 2,
            size.height * 0.75,
          )
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  _HexagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
