import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Semi-transparent overlay on the final Tetris frame with optional confetti.
class TetrisGameOverOverlay extends StatefulWidget {
  final int weeks;
  final bool isNewRecord;
  final VoidCallback onStartNewGame;

  const TetrisGameOverOverlay({
    super.key,
    required this.weeks,
    required this.isNewRecord,
    required this.onStartNewGame,
  });

  @override
  State<TetrisGameOverOverlay> createState() => _TetrisGameOverOverlayState();
}

class _TetrisGameOverOverlayState extends State<TetrisGameOverOverlay> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    if (widget.isNewRecord) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
        if (widget.isNewRecord)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 28,
              minBlastForce: 12,
              emissionFrequency: 0.08,
              numberOfParticles: 24,
              gravity: 0.18,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.pinkAccent,
                Colors.lightGreenAccent,
                Colors.cyanAccent,
                Colors.white,
              ],
            ),
          ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isNewRecord) ...[
                  Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.amber.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tetrisNewRecordCelebration(widget.weeks),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.amber.shade100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else
                  Text(
                    l10n.tetrisForecastWeeks(widget.weeks),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: widget.onStartNewGame,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(l10n.tetrisStartNewGame),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
