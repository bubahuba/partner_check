import 'dart:math';

import 'package:flutter/material.dart';

/// Canvas Tetris logic ported from the browser implementation.
class TetrisEngine {
  static const int hCount = 10;
  static const int vCount = 18;
  static const int originalSpeedMs = 750;
  static const int dropSpeedMs = 50;

  final List<Color> pieceColors;
  final void Function(Color landedColor)? onPieceLanded;
  final Random _random = Random();

  late List<List<TetrisCell>> _map;
  Tetromino? _currentPiece;
  int _orientation = 0;
  List<Point<int>> _objectPos = [];
  int _hPos = 4;
  int _vPos = 0;
  bool _newOb = true;
  DateTime _lastTick = DateTime.now();
  bool _glue = false;
  int _weeks = 0;
  int _speedMs = originalSpeedMs;
  bool _paused = false;
  bool _gameOver = false;

  TetrisEngine({
    required this.pieceColors,
    this.onPieceLanded,
  }) {
    resetGame();
  }

  int get weeks => _weeks;
  bool get isPaused => _paused;
  bool get isGameOver => _gameOver;
  int get speedMs => _speedMs;
  List<List<TetrisCell>> get map => _map;
  Color? get activePieceColor => _currentPiece?.fill;

  void resetGame() {
    _map = List.generate(
      hCount,
      (_) => List.generate(vCount, (_) => const TetrisCell.empty()),
    );
    _glue = false;
    _newOb = true;
    _vPos = 0;
    _orientation = 0;
    _hPos = 4;
    _weeks = 0;
    _speedMs = originalSpeedMs;
    _gameOver = false;
    _objectPos = [];
    _currentPiece = null;
    _lastTick = DateTime.now();
  }

  void setPaused(bool paused) {
    _paused = paused;
  }

  void setSoftDrop(bool active) {
    _speedMs = active ? dropSpeedMs : originalSpeedMs;
  }

  /// Advance game state. Returns final week count when game over occurs.
  int? tick() {
    if (_paused || _gameOver) return null;

    var removeLines = false;
    var settleColor = 0;

    if (_glue) {
      removeLines = true;
      _glue = false;
      _newOb = true;
      settleColor = (_currentPiece?.fill.toARGB32() ?? 0) & 0xFFFFFF;
      _vPos = 0;
      _hPos = 4;
      _orientation = 0;
    }

    for (final pos in _objectPos) {
      _map[pos.x][pos.y] = settleColor != 0
          ? TetrisCell.settled(settleColor)
          : const TetrisCell.empty();
    }
    _objectPos = [];

    if (removeLines) {
      _removeFullLines();
    }

    if (_newOb) {
      _currentPiece = _randomPiece();
    }

    _syncActivePieceOnMap();

    final piece = _currentPiece!;
    final cells = piece.cells(_orientation);

    final now = DateTime.now();
    if (now.difference(_lastTick).inMilliseconds > _speedMs) {
      final columns = <int, int>{};
      for (final offset in cells) {
        final x = _hPos + offset.x;
        final y = _vPos + offset.y;
        if (y < 0) continue;
        columns[x] = max(columns[x] ?? y, y);
      }

      for (final entry in columns.entries) {
        final x = entry.key;
        final y = entry.value;
        if (y == vCount - 1 || _blocksPiece(x, y + 1)) {
          _glue = true;
          if (_newOb) {
            final finalWeeks = _weeks;
            _settleActivePiece();
            _gameOver = true;
            return finalWeeks;
          }
          final landed = _currentPiece?.fill;
          if (landed != null) {
            onPieceLanded?.call(landed);
          }
          _speedMs = originalSpeedMs;
          _newOb = false;
          return null;
        }
      }

      _lastTick = now;
      _vPos += 1;
      _syncActivePieceOnMap();
    }

    _newOb = false;
    return null;
  }

  bool moveLeft() {
    if (!_tryMove(-1)) return false;
    _syncActivePieceOnMap();
    return true;
  }

  bool moveRight() {
    if (!_tryMove(1)) return false;
    _syncActivePieceOnMap();
    return true;
  }

  bool rotate() {
    if (_currentPiece == null) return false;
    final newOr = (_orientation + 1) % 4;
    for (final kick in const [0, -1, 1, -2, 2]) {
      if (_fitsPiece(newOr, hPos: _hPos + kick, vPos: _vPos)) {
        _orientation = newOr;
        _hPos += kick;
        _syncActivePieceOnMap();
        return true;
      }
    }
    return false;
  }

  /// Whether [orientation] fits at [hPos]/[vPos] inside the playfield.
  bool _fitsPiece(int orientation, {required int hPos, required int vPos}) {
    for (final offset in _currentPiece!.cells(orientation)) {
      final x = hPos + offset.x;
      final y = vPos + offset.y;
      if (x < 0 || x >= hCount) return false;
      if (y >= vCount) return false;
      if (y >= 0 && _map[x][y].isSettled) return false;
    }
    return true;
  }

  bool _blocksPiece(int x, int y) {
    if (y < 0 || y >= vCount) return false;
    return _map[x][y].isSettled;
  }

  void _settleActivePiece() {
    final settleColor = (_currentPiece?.fill.toARGB32() ?? 0) & 0xFFFFFF;
    for (final pos in _objectPos) {
      if (settleColor != 0) {
        _map[pos.x][pos.y] = TetrisCell.settled(settleColor);
      }
    }
    _objectPos = [];
    _currentPiece = null;
  }

  void _syncActivePieceOnMap() {
    for (final pos in _objectPos) {
      _map[pos.x][pos.y] = const TetrisCell.empty();
    }
    _objectPos = [];

    final piece = _currentPiece;
    if (piece == null) return;

    for (final offset in piece.cells(_orientation)) {
      final x = _hPos + offset.x;
      final y = _vPos + offset.y;
      if (x >= 0 && x < hCount && y >= 0 && y < vCount) {
        _map[x][y] = TetrisCell.active();
        _objectPos.add(Point(x, y));
      }
    }
  }

  bool _tryMove(int side) {
    if (_currentPiece == null) return false;
    if (!_fitsPiece(_orientation, hPos: _hPos + side, vPos: _vPos)) {
      return false;
    }
    _hPos += side;
    return true;
  }

  void _removeFullLines() {
    for (var i = vCount - 1; i > 0; i--) {
      var line = true;
      for (var j = 0; j < hCount; j++) {
        if (!_map[j][i].isSettled) {
          line = false;
          break;
        }
      }

      if (line) {
        for (var k = i; k > 0; k--) {
          for (var j = 0; j < hCount; j++) {
            _map[j][k] = _map[j][k - 1];
          }
        }
        i++;
        _weeks++;
      }
    }
  }

  Tetromino _randomPiece() {
    final index = _random.nextInt(_tetrominoes.length);
    final template = _tetrominoes[index];
    final color = pieceColors[_random.nextInt(pieceColors.length)];
    return Tetromino(cellsByOrientation: template, fill: color);
  }

  static final List<List<List<Point<int>>>> _tetrominoes = [
    // Cube
    [
      [Point(0, 0), Point(1, 1), Point(0, 1), Point(1, 0)],
      [Point(0, 0), Point(1, 1), Point(0, 1), Point(1, 0)],
      [Point(0, 0), Point(1, 1), Point(0, 1), Point(1, 0)],
      [Point(0, 0), Point(1, 1), Point(0, 1), Point(1, 0)],
    ],
    // Normal L
    [
      [Point(0, 0), Point(1, 0), Point(1, 1), Point(1, 2)],
      [Point(0, 1), Point(1, 1), Point(2, 1), Point(2, 0)],
      [Point(0, 0), Point(0, 1), Point(0, 2), Point(1, 2)],
      [Point(0, 0), Point(1, 0), Point(2, 0), Point(0, 1)],
    ],
    // Reverse L
    [
      [Point(0, 0), Point(1, 0), Point(0, 1), Point(0, 2)],
      [Point(0, 0), Point(1, 0), Point(2, 0), Point(2, 1)],
      [Point(1, 0), Point(1, 1), Point(1, 2), Point(0, 2)],
      [Point(0, 0), Point(0, 1), Point(1, 1), Point(2, 1)],
    ],
    // S
    [
      [Point(0, 1), Point(1, 1), Point(1, 0), Point(2, 0)],
      [Point(0, 0), Point(0, 1), Point(1, 1), Point(1, 2)],
      [Point(0, 1), Point(1, 1), Point(1, 0), Point(2, 0)],
      [Point(0, 0), Point(0, 1), Point(1, 1), Point(1, 2)],
    ],
    // Z
    [
      [Point(0, 0), Point(1, 0), Point(1, 1), Point(2, 1)],
      [Point(1, 0), Point(1, 1), Point(0, 1), Point(0, 2)],
      [Point(0, 0), Point(1, 0), Point(1, 1), Point(2, 1)],
      [Point(1, 0), Point(1, 1), Point(0, 1), Point(0, 2)],
    ],
    // T
    [
      [Point(0, 0), Point(1, 0), Point(2, 0), Point(1, 1)],
      [Point(0, -1), Point(0, 0), Point(0, 1), Point(1, 0)],
      [Point(0, 0), Point(1, -1), Point(2, 0), Point(1, 0)],
      [Point(2, -1), Point(1, 0), Point(2, 0), Point(2, 1)],
    ],
    // Pipe (I)
    [
      [Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3)],
      [Point(-1, 1), Point(0, 1), Point(1, 1), Point(2, 1)],
      [Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3)],
      [Point(-1, 1), Point(0, 1), Point(1, 1), Point(2, 1)],
    ],
  ];
}

class TetrisCell {
  final bool isActive;
  final int? settledColor;

  const TetrisCell._({required this.isActive, this.settledColor});

  const TetrisCell.empty() : this._(isActive: false, settledColor: null);

  const TetrisCell.active() : this._(isActive: true, settledColor: null);

  const TetrisCell.settled(int color)
      : this._(isActive: false, settledColor: color);

  bool get isEmpty => !isActive && settledColor == null;
  bool get isSettled => settledColor != null;
}

class Tetromino {
  final List<List<Point<int>>> cellsByOrientation;
  final Color fill;

  Tetromino({required this.cellsByOrientation, required this.fill});

  List<Point<int>> cells(int orientation) =>
      cellsByOrientation[orientation % 4];
}
