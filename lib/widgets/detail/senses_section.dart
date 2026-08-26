import 'package:flutter/material.dart';

import '../../models/search_result.dart';
import '../../utils/lexical_helpers.dart';
import '../clickable_span_builder.dart';

class SensesSection extends StatelessWidget {
  final List<Map<String, dynamic>> senses;
  final List<String> allPosLabels;
  final Map<int, List<SearchResult>> entrySynonyms;
  final Map<int, List<SearchResult>> entryAntonyms;
  final List<Map<String, dynamic>> expressions;
  final ClickableSpanBuilder spanBuilder;
  final bool isDark;

  const SensesSection({
    super.key,
    required this.senses,
    required this.allPosLabels,
    required this.entrySynonyms,
    required this.entryAntonyms,
    required this.expressions,
    required this.spanBuilder,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (senses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No hay acepciones disponibles.',
          style: TextStyle(
            fontFamily: 'serif',
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      );
    }

    final Set<int> displayedSynonymPids = {};
    final Set<int> displayedAntonymPids = {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Acepciones numeradas ───────────────────────────────────────────
        ...senses.asMap().entries.map((entry) {
          final idx = entry.key;
          final sense = entry.value;
          final gloss = (sense['gloss'] as String?) ?? '';
          final sensePos = (sense['pos_label'] as String?)?.trim() ?? '';
          final parsedTags = parseTags(sense['raw_tags']);
          final int palabraId = (sense['palabra_id'] as int?) ?? 0;

          final String? posText = (allPosLabels.length > 1 && sensePos.isNotEmpty)
              ? abbreviatePos(sensePos)
              : (idx == 0 && allPosLabels.isEmpty && sensePos.isNotEmpty ? abbreviatePos(sensePos) : null);

          final isAdj = sensePos.toLowerCase().contains('adjetivo') ||
              allPosLabels.any((l) => l.toLowerCase().contains('adjetivo'));
          final isNoun = sensePos.toLowerCase().contains('sustantivo') ||
              allPosLabels.any((l) => l.toLowerCase().contains('sustantivo'));
          final isVerb = sensePos.toLowerCase().contains('verbo') ||
              allPosLabels.any((l) => l.toLowerCase().contains('verbo'));

          final List<String> contextTags = parsedTags.where((t) {
            final low = t.toLowerCase().trim();
            if (isAdj &&
                (low == 'adjetivo' ||
                    low == 'adj' ||
                    low == 'adj.' ||
                    low == 'u. t. c. adj.' ||
                    low.contains('como adjetivo'))) {
              return false;
            }
            if (isNoun &&
                (low == 'sustantivo' ||
                    low == 'sust' ||
                    low == 'sust.' ||
                    low == 'u. t. c. s.' ||
                    low.contains('como sustantivo'))) {
              return false;
            }
            if (isVerb &&
                (low == 'verbo' || low == 'verb' || low == 'v.' || low.contains('como verbo'))) {
              return false;
            }
            if (low == sensePos.toLowerCase() ||
                low == abbreviatePos(sensePos).replaceAll('.', '').toLowerCase()) {
              return false;
            }
            return true;
          }).toList();

          // Sinónimos y antónimos asociados a esta acepción/entrada
          final List<SearchResult> senseSyns = (!displayedSynonymPids.contains(palabraId))
              ? (entrySynonyms[palabraId] ?? [])
              : [];
          if (senseSyns.isNotEmpty) displayedSynonymPids.add(palabraId);

          final List<SearchResult> senseAnts = (!displayedAntonymPids.contains(palabraId))
              ? (entryAntonyms[palabraId] ?? [])
              : [];
          if (senseAnts.isNotEmpty) displayedAntonymPids.add(palabraId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${idx + 1}. ',
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                    color: isDark ? const Color(0xFFF0A500) : const Color(0xFFB45309),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      spanBuilder.buildGloss(
                        gloss: gloss,
                        posText: posText,
                        contextTags: contextTags,
                      ),
                      if (senseSyns.isNotEmpty)
                        spanBuilder.buildInlineSynonyms(
                          prefix: 'Sin.:',
                          items: senseSyns,
                          isAntonym: false,
                        ),
                      if (senseAnts.isNotEmpty)
                        spanBuilder.buildInlineSynonyms(
                          prefix: 'Ant.:',
                          items: senseAnts,
                          isAntonym: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        // ── Expresiones y Locuciones (Estilo RAE) ──────────────────────────
        if (expressions.isNotEmpty) ...[
          const SizedBox(height: 16),
          for (final exprItem in expressions) ...[
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Text(
                exprItem['expression'] as String,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFFB923C) : const Color(0xFFC2410C),
                ),
              ),
            ),
            for (final s in (exprItem['senses'] as List).cast<Map<String, dynamic>>())
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((exprItem['senses'] as List).length > 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 8, top: 1),
                        child: Text(
                          '${s['order_num']}.',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? const Color(0xFFF0A500) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    Expanded(
                      child: spanBuilder.buildGloss(
                        gloss: s['gloss'] as String? ?? '',
                        posText: s['pos_label'] as String? ?? '',
                        contextTags: [],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ],
    );
  }
}
