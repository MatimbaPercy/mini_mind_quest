import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class WordHuntGame extends StatefulWidget {
  final VoidCallback onCompleted;

  const WordHuntGame({super.key, required this.onCompleted});

  @override
  State<WordHuntGame> createState() => _WordHuntGameState();
}

class _WordHuntGameState extends State<WordHuntGame> {
  static const int _gridSize = 10;
  static const int _wordsPerGame = 5;

  static const List<String> _wordPool = [
    'SUN',
    'CAT',
    'DOG',
    'BALL',
    'TREE',
    'CAR',
    'STAR',
    'MOON',
    'BOOK',
    'CAKE',
    'DUCK',
    'FISH',
    'FROG',
    'LION',
    'BEAR',
    'BIRD',
    'BOAT',
    'DOLL',
    'DRUM',
    'KITE',
  ];

  late List<String> _sessionWords;
  final Set<String> _foundWords = {};
  late List<List<String>> _grid;
  final List<_GridIndex> _currentSelection = [];
  final Set<_GridIndex> _foundIndices = {};
  bool _isDragging = false;
  final GlobalKey _gridKey = GlobalKey();

  final List<Color> _letterColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  late ConfettiController _confettiController;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _startNewGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _startNewGame() {
    _foundWords.clear();
    _foundIndices.clear();
    _currentSelection.clear();

    final wordPoolCopy = List<String>.from(_wordPool)..shuffle(Random());
    _sessionWords = wordPoolCopy.take(_wordsPerGame).toList();
    _grid = _generateGrid(_sessionWords);
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _currentSelection.clear();
    _updateSelection(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    _updateSelection(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    String selectedWord =
        _currentSelection.map((index) => _grid[index.row][index.col]).join();
    String reversedSelectedWord = selectedWord.split('').reversed.join();

    if (_sessionWords.contains(selectedWord) &&
        !_foundWords.contains(selectedWord)) {
      _foundWords.add(selectedWord);
      _foundIndices.addAll(_currentSelection);
    } else if (_sessionWords.contains(reversedSelectedWord) &&
        !_foundWords.contains(reversedSelectedWord)) {
      _foundWords.add(reversedSelectedWord);
      _foundIndices.addAll(_currentSelection);
    }

    setState(() => _currentSelection.clear());

    if (_foundWords.length == _sessionWords.length) {
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 800), () async {
        if (mounted) widget.onCompleted();
      });
    }
  }

  void _updateSelection(Offset localPosition) {
    final RenderBox? box =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final double cellWidth = box.size.width / _grid[0].length;
    final double cellHeight = box.size.height / _grid.length;

    final int col = (localPosition.dx / cellWidth).floor();
    final int row = (localPosition.dy / cellHeight).floor();

    if (row >= 0 && row < _grid.length && col >= 0 && col < _grid[0].length) {
      final index = _GridIndex(row, col);
      if (!_currentSelection.contains(index)) {
        if (_currentSelection.isEmpty ||
            (index.row - _currentSelection.last.row).abs() <= 1 &&
                (index.col - _currentSelection.last.col).abs() <= 1) {
          setState(() => _currentSelection.add(index));
        }
      }
    }
  }

  List<List<String>> _generateGrid(List<String> words) {
    final random = Random();
    List<List<String>> grid = List.generate(
      _gridSize,
      (_) => List.generate(_gridSize, (_) => ''),
    );

    const directions = [
      [0, 1],
      [1, 0],
    ];

    for (final word in words) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 50) {
        attempts++;
        final dir = directions[random.nextInt(directions.length)];
        final rowDir = dir[0];
        final colDir = dir[1];
        final startRow = random.nextInt(_gridSize);
        final startCol = random.nextInt(_gridSize);

        if (_canPlaceWord(grid, word, startRow, startCol, rowDir, colDir)) {
          for (int i = 0; i < word.length; i++) {
            grid[startRow + i * rowDir][startCol + i * colDir] = word[i];
          }
          placed = true;
        }
      }
    }

    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        if (grid[r][c] == '') {
          grid[r][c] = String.fromCharCode(random.nextInt(26) + 65);
        }
      }
    }

    return grid;
  }

  bool _canPlaceWord(
    List<List<String>> grid,
    String word,
    int startRow,
    int startCol,
    int rowDir,
    int colDir,
  ) {
    int endRow = startRow + (word.length - 1) * rowDir;
    int endCol = startCol + (word.length - 1) * colDir;
    if (endRow < 0 || endRow >= _gridSize || endCol < 0 || endCol >= _gridSize)
      return false;

    for (int i = 0; i < word.length; i++) {
      int r = startRow + i * rowDir;
      int c = startCol + i * colDir;
      if (grid[r][c] != '' && grid[r][c] != word[i]) return false;
    }
    return true;
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
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Find these words:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children:
                      _sessionWords.map((word) {
                        final isFound = _foundWords.contains(word);
                        return Text(
                          word,
                          style: TextStyle(
                            fontSize: 18,
                            decoration:
                                isFound ? TextDecoration.lineThrough : null,
                            color:
                                isFound
                                    ? Colors.grey.shade700
                                    : Colors.deepPurple,
                            fontWeight:
                                isFound ? FontWeight.normal : FontWeight.bold,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1,
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: GridView.builder(
                      key: _gridKey,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _grid[0].length,
                      ),
                      itemCount: _grid.length * _grid[0].length,
                      itemBuilder: (context, index) {
                        final int row = index ~/ _grid[0].length;
                        final int col = index % _grid[0].length;
                        final gridIndex = _GridIndex(row, col);

                        final isSelected = _currentSelection.contains(
                          gridIndex,
                        );
                        final isFound = _foundIndices.contains(gridIndex);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color:
                                isFound
                                    ? Colors.greenAccent.withOpacity(0.7)
                                    : isSelected
                                    ? Colors.blueAccent.withOpacity(0.6)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Center(
                            child: Text(
                              _grid[row][col],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color:
                                    _letterColors[(row * _gridSize + col) %
                                        _letterColors.length],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
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

class _GridIndex {
  final int row;
  final int col;

  const _GridIndex(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GridIndex &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
