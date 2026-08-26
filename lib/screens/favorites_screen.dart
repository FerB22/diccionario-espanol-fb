import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database_helper.dart';
import '../models/search_result.dart';
import 'word_detail_screen.dart';

const Color _dorado     = Color(0xFFF0A500);
const Color _azulMarino = Color(0xFF1A2C56);

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<SearchResult> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await DatabaseHelper().getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favs;
        _loading   = false;
      });
    }
  }

  Future<void> _removeFavorite(SearchResult r) async {
    await DatabaseHelper().removeFromFavorites(r.id);
    await _loadFavorites();
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
        backgroundColor: isDark ? const Color(0xFF0F172A) : _dorado,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Favoritos',
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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _dorado))
          : _favorites.isEmpty
              ? _buildEmpty(isDark)
              : _buildList(isDark),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border, size: 72, color: isDark ? Colors.grey[700] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no hay favoritos',
            style: TextStyle(
              fontSize: 17,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega palabras pulsando ★ en su definición',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isDark) {
    return ListView.separated(
      itemCount: _favorites.length,
      separatorBuilder: (_, __) => Divider(height: 1, indent: 16, color: isDark ? Colors.grey[800] : null),
      itemBuilder: (ctx, i) {
        final r = _favorites[i];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                icon: const Icon(Icons.star, color: _dorado),
                tooltip: 'Quitar de favoritos',
                onPressed: () => _removeFavorite(r),
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
            _loadFavorites();
          },
        );
      },
    );
  }
}