import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database_helper.dart';
import '../models/search_result.dart';
import 'word_detail_screen.dart';

const Color _carmesin   = Color(0xFF8B1A1A);
const Color _azulMarino = Color(0xFF1A2C56);
const Color _dorado     = Color(0xFFF0A500);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SearchResult> _history   = [];
  Set<int> _favoriteIds         = {};
  bool _loading                 = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final histList = await db.getHistory();
    final favList  = await db.getFavorites();
    if (mounted) {
      setState(() {
        _history     = histList;
        _favoriteIds = favList.map((f) => f.id).toSet();
        _loading     = false;
      });
    }
  }

  Future<void> _toggleFavorite(SearchResult r) async {
    final db = DatabaseHelper();
    if (_favoriteIds.contains(r.id)) {
      await db.removeFromFavorites(r.id);
      setState(() => _favoriteIds.remove(r.id));
    } else {
      await db.addToFavorites(r.id, r.word);
      setState(() => _favoriteIds.add(r.id));
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Deseas eliminar todo el historial de búsqueda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: _carmesin),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper().clearHistory();
      if (mounted) {
        setState(() {
          _history = [];
        });
      }
    }
  }

  void _share(SearchResult r) {
    Share.share(r.word, subject: r.word);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : _carmesin,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Historial',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: _history.isNotEmpty
          ? BottomAppBar(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFFEF4444) : _carmesin,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                  label: const Text('Limpiar historial'),
                  onPressed: _clearHistory,
                ),
              ),
            )
          : null,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: isDark ? const Color(0xFFEF4444) : _carmesin))
          : _history.isEmpty
              ? _buildEmpty(isDark)
              : _buildList(isDark),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 72, color: isDark ? Colors.grey[700] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'El historial está vacío',
            style: TextStyle(fontSize: 17, color: isDark ? Colors.grey[400] : Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Las palabras que consultes aparecerán aquí',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isDark) {
    return ListView.separated(
      itemCount: _history.length,
      separatorBuilder: (_, __) => Divider(height: 1, indent: 16, color: isDark ? Colors.grey[800] : null),
      itemBuilder: (ctx, i) {
        final r         = _history[i];
        final isFav     = _favoriteIds.contains(r.id);

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(Icons.history, color: isDark ? const Color(0xFFF87171) : _carmesin, size: 22),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.share, color: isDark ? Colors.grey[400] : Colors.grey),
                tooltip: 'Compartir',
                onPressed: () => _share(r),
              ),
              IconButton(
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: isFav ? _dorado : (isDark ? Colors.grey[600] : Colors.grey),
                ),
                tooltip: isFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                onPressed: () => _toggleFavorite(r),
              ),
            ],
          ),
          onTap: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 240),
                reverseTransitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    WordDetailScreen(
                  wordId: r.id,
                  word: r.word,
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
            _loadData();
          },
        );
      },
    );
  }
}