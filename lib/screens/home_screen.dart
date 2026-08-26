import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database_helper.dart';
import '../models/search_result.dart';
import '../widgets/app_drawer.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'search_results_screen.dart';
import 'word_detail_screen.dart';

// ── Paleta ───────────────────────────────────────────────────────────────────
const Color _azulMarino = Color(0xFF1A2C56);
const Color _dorado     = Color(0xFFF0A500);

// ── Modos de búsqueda ────────────────────────────────────────────────────────
const List<Map<String, dynamic>> _searchModes = [
  {'label': 'PALABRA',         'mode': 'comienza',  'color': Color(0xFFF0A500)},
  {'label': 'EXPRESIONES',     'mode': 'expresion',  'color': Color(0xFFFF8C00)},
  {'label': 'EXACTA',          'mode': 'exacta',    'color': Color(0xFFD32F2F)},
  {'label': 'COMIENZA POR...', 'mode': 'comienza',  'color': Color(0xFF388E3C)},
  {'label': 'TERMINA EN...',   'mode': 'termina',   'color': Color(0xFF7B1FA2)},
  {'label': 'CONTIENE...',     'mode': 'contiene',  'color': Color(0xFF1976D2)},
  {'label': 'ANAGRAMAS',       'mode': 'anagrama',  'color': Color(0xFF00796B)},
  {'label': 'ALEATORIA',       'mode': 'aleatoria', 'color': Color(0xFF616161)},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchMode = 'comienza';
  String _searchModeLabel = 'COMIENZA POR...';
  SearchResult? _wordOfDay;
  bool _loadingWord = true;

  @override
  void initState() {
    super.initState();
    _loadWordOfDay();
  }

  Future<void> _loadWordOfDay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final savedDate = prefs.getString('word_of_day_date');
      final savedId = prefs.getInt('word_of_day_id');
      final savedWord = prefs.getString('word_of_day_word');
      final savedPos = prefs.getString('word_of_day_pos') ?? '';
      final savedPosLabel = prefs.getString('word_of_day_pos_label') ?? '';

      if (savedDate == todayKey && savedId != null && savedWord != null) {
        if (mounted) {
          setState(() {
            _wordOfDay = SearchResult(
              id: savedId,
              word: savedWord,
              pos: savedPos,
              posLabel: savedPosLabel,
            );
            _loadingWord = false;
          });
        }
        return;
      }

      final word = await DatabaseHelper().getRandomWord();
      if (word != null) {
        await prefs.setString('word_of_day_date', todayKey);
        await prefs.setInt('word_of_day_id', word.id);
        await prefs.setString('word_of_day_word', word.word);
        await prefs.setString('word_of_day_pos', word.pos);
        await prefs.setString('word_of_day_pos_label', word.posLabel);
      }

      if (mounted) {
        setState(() {
          _wordOfDay = word;
          _loadingWord = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingWord = false;
        });
      }
    }
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
                      selected: _searchMode == m['mode'] &&
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
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 240),
                                reverseTransitionDuration: const Duration(milliseconds: 200),
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    WordDetailScreen(wordId: word.id, word: word.word),
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
                          }
                          return;
                        }
                        setState(() {
                          _searchMode      = mode;
                          _searchModeLabel = label;
                        });
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

  void _goToSearch() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 150),
        reverseTransitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (context, animation, secondaryAnimation) =>
            SearchResultsScreen(initialMode: _searchMode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: screenWidth,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : _azulMarino,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: _goToSearch,
          child: Container(
            height: 42,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14),
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
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: isDark ? const Color(0xFFF0A500) : _azulMarino,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Buscar palabra... ($_searchModeLabel)',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      fontSize: 14.5,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            tooltip: 'Modo de búsqueda',
            onPressed: _showSearchModeSheet,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SizedBox.expand(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            if (details.primaryDelta != null && details.primaryDelta! > 8) {
              _scaffoldKey.currentState?.openDrawer();
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Palabra del día ──────────────────────────────────────────────
            Card(
              elevation: isDark ? 1 : 3,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: _dorado, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Palabra del día',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_loadingWord)
                      CircularProgressIndicator(color: isDark ? _dorado : _azulMarino)
                    else if (_wordOfDay != null) ...[
                      Text(
                        _wordOfDay!.word,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Playfair',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : _azulMarino,
                        ),
                      ),
                      if (_wordOfDay!.posLabel.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Chip(
                          label: Text(
                            _wordOfDay!.posLabel,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? const Color(0xFF93C5FD) : _azulMarino,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFFF0A500) : _azulMarino,
                          foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.book_outlined, size: 18),
                        label: Text(
                          'Ver definición',
                          style: TextStyle(
                            fontWeight: isDark ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 240),
                              reverseTransitionDuration: const Duration(milliseconds: 200),
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  WordDetailScreen(
                                wordId: _wordOfDay!.id,
                                word: _wordOfDay!.word,
                              ),
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
                        },
                      ),
                    ] else
                      const Text('No disponible'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // ── Logo textual ─────────────────────────────────────────────────
            Text(
              'Diccionario',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Playfair',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : _azulMarino,
                height: 1.1,
              ),
            ),
            Text(
              'de la lengua',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Playfair',
                fontSize: 28,
                color: isDark ? const Color(0xFFE2E8F0) : _azulMarino,
                height: 1.2,
              ),
            ),
            const Text(
              'española',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Playfair',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _dorado,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 40),

            // ── Accesos rápidos ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickBtn(
                  icon: Icons.star_rounded,
                  label: 'Favoritos',
                  color: _dorado,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ),
                ),
                _QuickBtn(
                  icon: Icons.history_rounded,
                  label: 'Historial',
                  color: isDark ? const Color(0xFFF87171) : const Color(0xFF8B1A1A),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),
                _QuickBtn(
                  icon: Icons.shuffle_rounded,
                  label: 'Aleatoria',
                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF4B5563),
                  onTap: () async {
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
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ),
),
),
),
);
  }
}

// ── Widget auxiliar ──────────────────────────────────────────────────────────

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}