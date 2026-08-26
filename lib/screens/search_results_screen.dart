import 'dart:async';

import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/search_result.dart';
import 'word_detail_screen.dart';

const Color _azulMarino = Color(0xFF1A2C56);
const Color _dorado     = Color(0xFFF0A500);

const List<Map<String, dynamic>> _searchModes = [
  {'label': 'PALABRA',         'mode': 'comienza',  'color': Color(0xFFF0A500)},
  {'label': 'EXPRESIONES',     'mode': 'expresion', 'color': Color(0xFFFF8C00)},
  {'label': 'EXACTA',          'mode': 'exacta',    'color': Color(0xFFD32F2F)},
  {'label': 'COMIENZA POR...', 'mode': 'comienza',  'color': Color(0xFF388E3C)},
  {'label': 'TERMINA EN...',   'mode': 'termina',   'color': Color(0xFF7B1FA2)},
  {'label': 'CONTIENE...',     'mode': 'contiene',  'color': Color(0xFF1976D2)},
  {'label': 'ANAGRAMAS',       'mode': 'anagrama',  'color': Color(0xFF00796B)},
  {'label': 'ALEATORIA',       'mode': 'aleatoria', 'color': Color(0xFF616161)},
];

class SearchResultsScreen extends StatefulWidget {
  final String initialMode;

  const SearchResultsScreen({super.key, required this.initialMode});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _controller;
  late String _mode;
  late String _searchModeLabel;
  List<SearchResult> _results = [];
  List<SearchResult> _recentSearches = [];
  bool _loading = false;
  Timer? _debounce;
  int _searchSeq = 0;

  // Etiquetas legibles para el hint
  static const Map<String, String> _modeLabels = {
    'comienza':  'Comienza por…',
    'termina':   'Termina en…',
    'contiene':  'Contiene…',
    'exacta':    'Búsqueda exacta',
    'anagrama':  'Anagramas de…',
    'expresion': 'Expresiones con…',
    'aleatoria': 'Aleatoria',
  };

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    final matched = _searchModes.firstWhere(
      (m) => m['mode'] == _mode,
      orElse: () => {'label': 'COMIENZA POR...'},
    );
    _searchModeLabel = matched['label'] as String;
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
    _loadRecentSearches();
  }

  void _showSearchModeSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Modo de búsqueda',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF0A500) : _azulMarino,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _searchModes.map((m) => ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                      leading: Container(
                        width: 5,
                        height: 32,
                        decoration: BoxDecoration(
                          color: m['color'] as Color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      title: Text(
                        m['label'] as String,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: _searchModeLabel == m['label'] ? FontWeight.bold : FontWeight.w600,
                          color: _searchModeLabel == m['label']
                              ? (isDark ? const Color(0xFFF0A500) : _azulMarino)
                              : (isDark ? Colors.white : Colors.black87),
                          letterSpacing: 0.5,
                        ),
                      ),
                      selected: _mode == m['mode'] &&
                                _searchModeLabel == m['label'],
                      selectedTileColor: isDark
                          ? const Color(0xFF334155)
                          : _azulMarino.withOpacity(0.06),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final label = m['label'] as String;
                        final mode  = m['mode']  as String;
                        if (label == 'ALEATORIA') {
                          final word = await DatabaseHelper().getRandomWord();
                          if (word != null && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WordDetailScreen(
                                  wordId: word.id,
                                  word: word.word,
                                ),
                              ),
                            );
                          }
                          return;
                        }
                        setState(() {
                          _mode            = mode;
                          _searchModeLabel = label;
                        });
                        if (_controller.text.trim().isNotEmpty) {
                          _runSearch();
                        }
                      },
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadRecentSearches() async {
    final history = await DatabaseHelper().getHistory();
    if (mounted) {
      setState(() {
        _recentSearches = history;
      });
    }
  }

  Future<void> _deleteRecent(SearchResult r) async {
    await DatabaseHelper().removeFromHistory(r.id);
    _loadRecentSearches();
  }

  Future<void> _clearAllRecent() async {
    await DatabaseHelper().clearHistory();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), _runSearch);
  }

  Future<void> _runSearch() async {
    final q = _controller.text.trim();
    final currentSeq = ++_searchSeq;
    if (q.isEmpty) {
      if (mounted) setState(() => _results = []);
      return;
    }
    if (mounted) setState(() => _loading = true);
    final res = await DatabaseHelper().searchWords(q, _mode, limit: 30);
    if (mounted && currentSeq == _searchSeq) {
      setState(() {
        _results = res;
        _loading = false;
      });
    }
  }

  Future<void> _goToDetail(SearchResult r) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            WordDetailScreen(wordId: r.id, word: r.word),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.23, 1.0, 0.32, 1.0),
            reverseCurve: Curves.easeInCubic,
          );
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.06, 0.0),
            end: Offset.zero,
          ).animate(curve);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            ),
          );
        },
      ),
    );
    _loadRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hint = _modeLabels[_mode] ?? 'Buscar…';
    final query = _controller.text.trim();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : _azulMarino,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            style: TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
            ),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '$hint ($_searchModeLabel)',
              hintStyle: TextStyle(
                fontFamily: 'sans-serif',
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              filled: false,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.grey, size: 18),
                      splashRadius: 16,
                      onPressed: () {
                        _controller.clear();
                        setState(() => _results = []);
                      },
                    )
                  : null,
            ),
          ),
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: _dorado,
                    strokeWidth: 2.2,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            tooltip: 'Modo: $_searchModeLabel',
            onPressed: _showSearchModeSheet,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(query, isDark),
    );
  }

  Widget _buildBody(String query, bool isDark) {
    if (query.isEmpty) {
      if (_recentSearches.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 19,
                    color: isDark ? const Color(0xFFF0A500) : const Color(0xFFB45309),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BÚSQUEDAS RECIENTES',
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? const Color(0xFFF0A500) : const Color(0xFFB45309),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _clearAllRecent,
                    child: Text(
                      'Borrar todo',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _recentSearches.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                ),
                itemBuilder: (ctx, i) {
                  final r = _recentSearches[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: Icon(
                      Icons.history_rounded,
                      size: 20,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    title: Text(
                      r.word,
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : _azulMarino,
                      ),
                    ),
                    subtitle: r.posLabel.isNotEmpty
                        ? Text(
                            r.posLabel,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          )
                        : null,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 17,
                        color: isDark ? Colors.white38 : Colors.grey[400],
                      ),
                      splashRadius: 18,
                      tooltip: 'Eliminar de recientes',
                      onPressed: () => _deleteRecent(r),
                    ),
                    onTap: () => _goToDetail(r),
                  );
                },
              ),
            ),
          ],
        );
      }

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Escribe para buscar',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (!_loading && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No se encontraron resultados',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              '"$query"',
              style: TextStyle(
                color: isDark ? const Color(0xFFF0A500) : _azulMarino,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => Divider(height: 1, indent: 16, color: isDark ? Colors.grey[800] : null),
      itemBuilder: (ctx, i) {
        final r = _results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            r.word,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : _azulMarino,
              fontSize: 16,
            ),
          ),
          subtitle: r.posLabel.isNotEmpty
              ? Text(
                  r.posLabel,
                  style: TextStyle(color: isDark ? const Color(0xFF93C5FD) : Colors.grey[600], fontSize: 13),
                )
              : null,
          trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey),
          onTap: () => _goToDetail(r),
        );
      },
    );
  }
}