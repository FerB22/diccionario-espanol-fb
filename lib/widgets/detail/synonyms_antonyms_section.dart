import 'package:flutter/material.dart';
import '../../models/search_result.dart';

const Color _azulMarino = Color(0xFF1A2C56);

class SynonymsAntonymsSection extends StatelessWidget {
  final List<SearchResult> synonyms;
  final List<SearchResult> antonyms;
  final void Function(int id, String word) onNavigate;
  final bool isDark;

  const SynonymsAntonymsSection({
    super.key,
    required this.synonyms,
    required this.antonyms,
    required this.onNavigate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sinónimos (Tarjeta Editorial Distinguida) ──────────────────────
        if (synonyms.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                  : const Color(0xFFF1F5F9).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 19,
                      color: isDark ? const Color(0xFF93C5FD) : _azulMarino,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Sinónimos (${synonyms.length})',
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF93C5FD) : _azulMarino,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: synonyms
                      .map(
                        (s) => Material(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 0.5,
                          child: InkWell(
                            onTap: () => onNavigate(s.id, s.word),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1),
                                  width: 0.9,
                                ),
                              ),
                              child: Text(
                                s.word,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 14.5,
                                  color: isDark
                                      ? const Color(0xFFE2E8F0)
                                      : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],

        // ── Antónimos (Tarjeta Editorial Distinguida) ──────────────────────
        if (antonyms.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2A1515).withValues(alpha: 0.45)
                  : const Color(0xFFFFF1F2).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF5A2323) : const Color(0xFFFECDD3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.compare_arrows_rounded,
                      size: 19,
                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFBE123C),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Antónimos (${antonyms.length})',
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFBE123C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: antonyms
                      .map(
                        (a) => Material(
                          color: isDark ? const Color(0xFF1F0D0D) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 0.5,
                          child: InkWell(
                            onTap: () => onNavigate(a.id, a.word),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF5A2323)
                                      : const Color(0xFFFDA4AF),
                                  width: 0.9,
                                ),
                              ),
                              child: Text(
                                a.word,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 14.5,
                                  color: isDark
                                      ? const Color(0xFFFECDD3)
                                      : const Color(0xFF881337),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
