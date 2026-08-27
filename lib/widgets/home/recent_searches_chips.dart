import 'package:flutter/material.dart';
import '../../models/search_result.dart';

class RecentSearchesChips extends StatelessWidget {
  final List<SearchResult> recentWords;
  final bool isDark;
  final ValueChanged<SearchResult> onSelectWord;

  const RecentSearchesChips({
    super.key,
    required this.recentWords,
    required this.isDark,
    required this.onSelectWord,
  });

  @override
  Widget build(BuildContext context) {
    if (recentWords.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: recentWords.map((item) {
        return InkWell(
          onTap: () => onSelectWord(item),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              item.word,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
