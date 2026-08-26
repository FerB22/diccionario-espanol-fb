import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database_helper.dart';
import '../models/search_result.dart';
import '../services/tts_service.dart';
import '../utils/lexical_helpers.dart';
import '../widgets/clickable_span_builder.dart';
import '../widgets/detail/etymology_card.dart';
import '../widgets/detail/history_bottom_bar.dart';
import '../widgets/detail/paronimo_card.dart';
import '../widgets/detail/senses_section.dart';
import '../widgets/detail/synonyms_antonyms_section.dart';
import '../widgets/detail/word_detail_header.dart';
import 'search_results_screen.dart';

const Color _azulMarino = Color(0xFF1A2C56);
const Color _dorado     = Color(0xFFF0A500);

class WordDetailScreen extends StatefulWidget {
  final int wordId;
  final String word;

  const WordDetailScreen({
    super.key,
    required this.wordId,
    required this.word,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  Map<String, dynamic>? _detail;
  bool _loading = true;
  bool _isFavorite = false;

  late int _currentWordId;
  late String _currentWord;
  List<Map<String, dynamic>> _historyStack = [];
  int _historyIndex = 0;
  final List<GestureRecognizer> _recognizers = [];

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  T _registerRecognizer<T extends GestureRecognizer>(T recognizer) {
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  void initState() {
    super.initState();
    _currentWordId = widget.wordId;
    _currentWord   = widget.word;
    _historyStack  = [{'id': widget.wordId, 'word': widget.word}];
    _historyIndex  = 0;
    TtsService.instance.init();
    _loadDataForWord(_currentWordId, _currentWord);
  }

  @override
  void dispose() {
    _clearRecognizers();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _loadDataForWord(int wordId, String word) async {
    setState(() {
      _loading = true;
    });

    final db = DatabaseHelper();
    final results = await Future.wait([
      db.getWordDetail(wordId),
      db.isFavorite(wordId),
    ]);

    await db.addToHistory(wordId, word);

    if (mounted) {
      setState(() {
        _currentWordId = wordId;
        _currentWord   = word;
        _detail        = results[0] as Map<String, dynamic>;
        _isFavorite    = results[1] as bool;
        _loading       = false;
      });
    }
  }

  void _goToWord(int wordId, String word) {
    if (_currentWordId == wordId) return;
    if (_historyIndex < _historyStack.length - 1) {
      _historyStack = _historyStack.sublist(0, _historyIndex + 1);
    }
    _historyStack.add({'id': wordId, 'word': word});
    _historyIndex = _historyStack.length - 1;
    _loadDataForWord(wordId, word);
  }

  void _goBack() {
    if (_historyIndex > 0) {
      _historyIndex--;
      final prev = _historyStack[_historyIndex];
      _loadDataForWord(prev['id'] as int, prev['word'] as String);
    } else {
      Navigator.pop(context);
    }
  }

  void _goForward() {
    if (_historyIndex < _historyStack.length - 1) {
      _historyIndex++;
      final next = _historyStack[_historyIndex];
      _loadDataForWord(next['id'] as int, next['word'] as String);
    }
  }

  Future<void> _toggleFavorite() async {
    final db = DatabaseHelper();
    if (_isFavorite) {
      await db.removeFromFavorites(_currentWordId);
    } else {
      await db.addToFavorites(_currentWordId, _currentWord);
    }
    if (mounted) setState(() => _isFavorite = !_isFavorite);
  }

  void _share() {
    final wordData = _detail?['word'] as Map<String, dynamic>?;
    final senses   = (_detail?['senses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final buffer   = StringBuffer();
    buffer.writeln(_currentWord.toUpperCase());
    if (wordData != null && (wordData['pos_label'] as String?) != null) {
      buffer.writeln(wordData['pos_label'] as String? ?? '');
    }
    for (int i = 0; i < senses.length; i++) {
      final gloss = (senses[i]['gloss'] as String?) ?? '';
      if (gloss.isNotEmpty) buffer.writeln('${i + 1}. $gloss');
    }
    buffer.writeln('\nCompartido desde Diccionario de la lengua española');
    Share.share(buffer.toString(), subject: _currentWord);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : _azulMarino,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: 'Atrás',
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 160),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SearchResultsScreen(initialMode: 'comienza'),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            height: 42,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _currentWord,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2C56),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.search_rounded, color: Color(0xFFF0A500), size: 22),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: _isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: _toggleFavorite,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim,
                  curve: const Cubic(0.23, 1.0, 0.32, 1.0),
                ),
                child: child,
              ),
              child: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey<bool>(_isFavorite),
                color: _isFavorite ? _dorado : Colors.white,
                size: 26,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'Compartir',
            onPressed: _share,
          ),
        ],
      ),
      bottomNavigationBar: HistoryBottomBar(
        historyStack: _historyStack,
        historyIndex: _historyIndex,
        onBack: _goBack,
        onForward: _goForward,
        isDark: isDark,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: isDark ? _dorado : _azulMarino))
          : _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    _clearRecognizers();

    final wordData    = _detail?['word'] as Map<String, dynamic>?;
    final senses      = (_detail?['senses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final sounds      = (_detail?['sounds'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final synonyms    = (_detail?['synonyms'] as List?)?.cast<SearchResult>() ?? [];
    final antonyms    = (_detail?['antonyms'] as List?)?.cast<SearchResult>() ?? [];
    final etymology   = _detail?['etymology'] as String?;
    final paronimo    = _detail?['paronimo'] as String?;
    final expressions = (_detail?['expressions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final posLabel = (wordData?['pos_label'] as String?) ?? '';
    final ipa      = sounds.isNotEmpty ? (sounds.first['ipa'] as String?) : null;

    final List<String> allPosLabels = [];
    for (final s in senses) {
      final pl = (s['pos_label'] as String?)?.trim() ?? '';
      if (pl.isNotEmpty && !allPosLabels.contains(pl)) {
        allPosLabels.add(pl);
      }
    }
    if (allPosLabels.isEmpty && posLabel.isNotEmpty) {
      allPosLabels.add(posLabel);
    }

    final entrySynonyms = (_detail?['entrySynonyms'] as Map<int, List<SearchResult>>?) ?? {};
    final entryAntonyms = (_detail?['entryAntonyms'] as Map<int, List<SearchResult>>?) ?? {};

    final displayLemma = formatDisplayLemma(_currentWord, allPosLabels);

    final spanBuilder = ClickableSpanBuilder(
      context: context,
      isDark: isDark,
      currentWord: _currentWord,
      onNavigate: _goToWord,
      registerRecognizer: _registerRecognizer,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WordDetailHeader(
            displayLemma: displayLemma,
            allPosLabels: allPosLabels,
            ipa: ipa,
            currentWord: _currentWord,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          if (etymology != null && etymology.isNotEmpty)
            EtymologyCard(etymology: etymology, isDark: isDark),
          SensesSection(
            senses: senses,
            allPosLabels: allPosLabels,
            entrySynonyms: entrySynonyms,
            entryAntonyms: entryAntonyms,
            expressions: expressions,
            spanBuilder: spanBuilder,
            isDark: isDark,
          ),
          ParonimoCard(
            paronimo: paronimo,
            spanBuilder: spanBuilder,
            isDark: isDark,
          ),
          SynonymsAntonymsSection(
            synonyms: synonyms,
            antonyms: antonyms,
            onNavigate: _goToWord,
            isDark: isDark,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
