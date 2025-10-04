import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';

class LogicMazeGame extends StatefulWidget {
  final VoidCallback onCompleted;

  const LogicMazeGame({super.key, required this.onCompleted});

  @override
  State<LogicMazeGame> createState() => _LogicMazeGameState();
}

class _LogicMazeGameState extends State<LogicMazeGame> {
  late List<List<int>> _maze;
  late int _playerRow;
  late int _playerCol;

  final int rows = 15;
  final int cols = 15;

  late ConfettiController _confettiController;
  InterstitialAd? _interstitialAd;

  // 🎵 Audio
  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _generateMazeDFS();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _interstitialAd?.dispose();
    _bgPlayer.stop();
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  // 🔊 Play effect
  Future<void> _playSound(String file) async {
    if (!_isMuted) {
      await _sfxPlayer.play(AssetSource('sounds/$file'));
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    if (_isMuted) {
      _bgPlayer.pause();
    }
  }

  // 🌀 Maze generation
  void _generateMazeDFS() {
    _maze = List.generate(rows, (_) => List.filled(cols, 1));
    final random = Random();
    List<List<bool>> visited = List.generate(
      rows,
      (_) => List.filled(cols, false),
    );

    void dfs(int r, int c) {
      visited[r][c] = true;
      _maze[r][c] = 0;

      final directions = [
        [0, 1],
        [0, -1],
        [1, 0],
        [-1, 0],
      ]..shuffle(random);

      for (var dir in directions) {
        int nr = r + dir[0] * 2;
        int nc = c + dir[1] * 2;

        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && !visited[nr][nc]) {
          _maze[r + dir[0]][c + dir[1]] = 0;
          dfs(nr, nc);
        }
      }
    }

    dfs(0, 0);

    // Extra random connections
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (_maze[i][j] == 1 && random.nextDouble() < 0.1) {
          final neighbors = [
            [i - 1, j],
            [i + 1, j],
            [i, j - 1],
            [i, j + 1],
          ];
          for (var n in neighbors) {
            int nr = n[0], nc = n[1];
            if (nr >= 0 &&
                nr < rows &&
                nc >= 0 &&
                nc < cols &&
                _maze[nr][nc] == 0) {
              _maze[i][j] = 0;
              break;
            }
          }
        }
      }
    }

    _playerRow = 0;
    _playerCol = 0;
    _maze[_playerRow][_playerCol] = 2; // Player
    _maze[rows - 1][cols - 1] = 3; // Goal
  }

  // 🚶 Move player
  void _movePlayer(int rowOffset, int colOffset) {
    int newRow = _playerRow + rowOffset;
    int newCol = _playerCol + colOffset;

    // ❌ Wrong move (into a wall)
    if (newRow < 0 ||
        newRow >= _maze.length ||
        newCol < 0 ||
        newCol >= _maze[0].length ||
        _maze[newRow][newCol] == 1) {
      _playSound("wrong.mp3"); // 🔊 Wrong move
      return;
    }

    // ✅ Valid move
    setState(() {
      _maze[_playerRow][_playerCol] = 0;
      _playerRow = newRow;
      _playerCol = newCol;

      if (_maze[_playerRow][_playerCol] == 3) {
        _maze[_playerRow][_playerCol] = 2;
        _handleCompletion();
      } else {
        _maze[_playerRow][_playerCol] = 2;
      }
    });

    _playSound("tap.mp3"); // 🔊 Tap sound
  }

  // 🎉 Completion
  void _handleCompletion() async {
    _confettiController.play();
    _playSound("correct.mp3");
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) widget.onCompleted();
  }

  Widget _buildCell(int value) {
    Widget? child;
    Color bgColor;

    switch (value) {
      case 0:
        bgColor = Colors.lightBlue.shade50;
        break;
      case 1:
        bgColor = Colors.green.shade700;
        child = const Text("🌳", style: TextStyle(fontSize: 18));
        break;
      case 2:
        bgColor = Colors.yellow.shade200;
        child = const Text("🐰", style: TextStyle(fontSize: 22));
        break;
      case 3:
        bgColor = Colors.pink.shade300;
        child = const Text("⭐", style: TextStyle(fontSize: 22));
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(1, 1)),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 26),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🎨 Background
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

        // 🎮 Main Game
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _maze[0].length / _maze.length,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _maze[0].length,
                    ),
                    itemCount: _maze.length * _maze[0].length,
                    itemBuilder: (context, index) {
                      int row = index ~/ _maze[0].length;
                      int col = index % _maze[0].length;
                      return _buildCell(_maze[row][col]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildControlButton(
                  Icons.arrow_upward,
                  () => _movePlayer(-1, 0),
                  Colors.orange,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      Icons.arrow_back,
                      () => _movePlayer(0, -1),
                      Colors.red,
                    ),
                    _buildControlButton(
                      Icons.arrow_forward,
                      () => _movePlayer(0, 1),
                      Colors.green,
                    ),
                  ],
                ),
                _buildControlButton(
                  Icons.arrow_downward,
                  () => _movePlayer(1, 0),
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),

        // 🎊 Confetti
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

        // 🔇 Mute button
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _toggleMute,
          ),
        ),
      ],
    );
  }
}
