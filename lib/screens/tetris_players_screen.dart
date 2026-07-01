import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services/contact_storage_service.dart';
import '../utils/self_contact_gradient.dart';
import '../widgets/tetris_board.dart';
import '../widgets/tetris_pair_miniature.dart';
import '../widgets/tetris_session_background.dart';

class TetrisPlayersScreen extends StatefulWidget {
  final Color? backgroundColor1;
  final Color? backgroundColor2;

  const TetrisPlayersScreen({
    super.key,
    this.backgroundColor1,
    this.backgroundColor2,
  });

  @override
  State<TetrisPlayersScreen> createState() => _TetrisPlayersScreenState();
}

class _TetrisPlayersScreenState extends State<TetrisPlayersScreen> {
  final ContactStorageService _storageService = ContactStorageService();
  List<TetrisPlayerRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await _storageService.loadTetrisRecords();
    records.sort((a, b) => b.bestWeeks.compareTo(a.bestWeeks));
    if (!mounted) return;
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(l10n.tetrisPlayersTitle),
      ),
      body: TetrisSessionBackground(
        color1:
            widget.backgroundColor1 ?? SelfContactGradientPalette.defaultInner,
        color2:
            widget.backgroundColor2 ?? SelfContactGradientPalette.defaultOuter,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = tetrisPlayfieldMaxWidth(
                context,
                availableHeight: constraints.maxHeight,
              );
              return SizedBox(
                width: maxWidth,
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _records.isEmpty
                        ? Center(
                            child: Text(
                              l10n.tetrisNoRecords,
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 16,
                            ),
                            itemCount: _records.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 24,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TetrisPairRowMiniatures(
                                      contact1Name: record.contact1Name,
                                      contact1Color: record.contact1Color,
                                      contact2Name: record.contact2Name,
                                      contact2Color: record.contact2Color,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.tetrisWeeks(record.bestWeeks),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              );
                            },
                          ),
              );
            },
          ),
        ),
      ),
    );
  }
}
