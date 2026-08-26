import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/search_result.dart';
import '../screens/word_detail_screen.dart';

class WordListTile extends StatelessWidget {
  final SearchResult result;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const WordListTile({
    super.key,
    required this.result,
    this.showFavoriteButton = true,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        result.word,
        style: const TextStyle(fontSize: 17, fontFamily: 'Playfair'),
      ),
      subtitle: result.posLabel.isNotEmpty
          ? Text(result.posLabel,
              style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.grey),
            iconSize: 20,
            onPressed: () {
              Share.share('${result.word} — Diccionario Español FB');
            },
          ),
          if (showFavoriteButton)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? const Color(0xFFF0A500) : Colors.grey,
              ),
              iconSize: 22,
              onPressed: onFavoriteToggle,
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WordDetailScreen(
              wordId: result.id,
              word: result.word,
            ),
          ),
        );
      },
    );
  }
}