import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database_helper.dart';
import '../models/search_result.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home/did_you_know_card.dart';
import '../widgets/home/recent_searches_chips.dart';
import '../widgets/home/word_of_day_card.dart';
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
  String _didYouKnowText = '';
  List<SearchResult> _recentSearches = [];
  bool _loadingWord = true;

  @override
  void initState() {
    super.initState();
    _loadWordOfDay();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final history = await DatabaseHelper().getHistory();
      if (history.isNotEmpty) {
        if (mounted) {
          setState(() {
            _recentSearches = history.take(5).toList();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _recentSearches = const [
              SearchResult(id: 0, word: 'sombra', pos: 'noun', posLabel: 'sustantivo'),
              SearchResult(id: 0, word: 'efímero', pos: 'adj', posLabel: 'adjetivo'),
              SearchResult(id: 0, word: 'quimera', pos: 'noun', posLabel: 'sustantivo'),
              SearchResult(id: 0, word: 'vestigio', pos: 'noun', posLabel: 'sustantivo'),
            ];
          });
        }
      }
    } catch (_) {}
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
      final savedFact = prefs.getString('word_of_day_fact');

      if (savedDate == todayKey && savedId != null && savedWord != null) {
        if (mounted) {
          setState(() {
            _wordOfDay = SearchResult(
              id: savedId,
              word: savedWord,
              pos: savedPos,
              posLabel: savedPosLabel,
            );
            _didYouKnowText = savedFact ?? _generateFact(savedWord, null, null);
            _loadingWord = false;
          });
        }
        return;
      }

      final word = await DatabaseHelper().getRandomWord();
      if (word != null) {
        final detail = await DatabaseHelper().getWordDetail(word.id);
        final etym = detail['etymology'] as String?;
        final senses = detail['senses'] as List?;
        final firstGloss = (senses != null && senses.isNotEmpty)
            ? (senses[0]['gloss'] as String?)
            : null;
        final fact = _generateFact(word.word, etym, firstGloss);

        await prefs.setString('word_of_day_date', todayKey);
        await prefs.setInt('word_of_day_id', word.id);
        await prefs.setString('word_of_day_word', word.word);
        await prefs.setString('word_of_day_pos', word.pos);
        await prefs.setString('word_of_day_pos_label', word.posLabel);
        await prefs.setString('word_of_day_fact', fact);

        if (mounted) {
          setState(() {
            _wordOfDay = word;
            _didYouKnowText = fact;
            _loadingWord = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingWord = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingWord = false;
        });
      }
    }
  }

  String _generateFact(String word, String? etymology, String? firstGloss) {
    if (etymology != null && etymology.trim().isNotEmpty) {
      return '«$word» $etymology';
    }
    if (firstGloss != null && firstGloss.trim().isNotEmpty) {
      return '«$word» se define como: $firstGloss';
    }
    return 'El español cuenta con más de 93.000 palabras registradas en el diccionario académico, enriquecidas por raíces del latín, griego, árabe y lenguas originarias.';
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
                            await Navigator.push(
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
                            _loadRecentSearches();
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

  void _goToSearch() async {
    await Navigator.push(
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
    _loadRecentSearches();
  }

  void _onSelectWord(SearchResult item) async {
    if (item.id > 0) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 240),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation, secondaryAnimation) =>
              WordDetailScreen(wordId: item.id, word: item.word),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: const Cubic(0.23, 1.0, 0.32, 1.0),
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0.0),
                end: Offset.zero,
              ).animate(curve),
              child: FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: child,
              ),
            );
          },
        ),
      );
    } else {
      final res = await DatabaseHelper().searchWords(item.word, 'exacta', limit: 1);
      if (res.isNotEmpty && mounted) {
        await Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 240),
            reverseTransitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (context, animation, secondaryAnimation) =>
                WordDetailScreen(wordId: res[0].id, word: res[0].word),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curve = CurvedAnimation(
                parent: animation,
                curve: const Cubic(0.23, 1.0, 0.32, 1.0),
                reverseCurve: Curves.easeInCubic,
              );
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0.0),
                  end: Offset.zero,
                ).animate(curve),
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    }
    _loadRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
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
      body: Stack(
        children: [
          Positioned.fill(
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── 1. Palabra del día ──────────────────────────────────
                          WordOfDayCard(
                            word: _wordOfDay,
                            loading: _loadingWord,
                            isDark: isDark,
                            onSelect: () {
                              if (_wordOfDay != null) {
                                _onSelectWord(_wordOfDay!);
                              }
                            },
                          ),

                          const SizedBox(height: 32),

                          // ── 2. Logotipo editorial central ───────────────────────
                          Text(
                            'Diccionario',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Playfair',
                              fontSize: 34,
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
                              fontSize: 26,
                              color: isDark ? const Color(0xFFE2E8F0) : _azulMarino,
                              height: 1.2,
                            ),
                          ),
                          const Text(
                            'española',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Playfair',
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: _dorado,
                              height: 1.1,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── 3. Buscadas recientemente ───────────────────────────
                          Text(
                            'BUSCADAS RECIENTEMENTE',
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: isDark ? const Color(0xFFF0A500) : const Color(0xFFB45309),
                            ),
                          ),
                          const SizedBox(height: 12),
                          RecentSearchesChips(
                            recentWords: _recentSearches,
                            isDark: isDark,
                            onSelectWord: _onSelectWord,
                          ),

                          const SizedBox(height: 28),

                          // ── 4. ¿Sabías que...? ──────────────────────────────────
                          DidYouKnowCard(
                            factText: _didYouKnowText,
                            isDark: isDark,
                          ),

                          // Espacio de resguardo para el botón flotante inferior
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 96),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 5. Botón flotante inferior fijo y fluido ──────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 28,
            child: Center(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _goToSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : _azulMarino,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: isDark
                          ? const BorderSide(color: Color(0xFF334155), width: 1.2)
                          : BorderSide.none,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                  ),
                  icon: const Icon(Icons.search_rounded, size: 20, color: _dorado),
                  label: const Text(
                    'Buscar',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
