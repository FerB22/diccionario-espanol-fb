import 'package:flutter/material.dart';
import '../../services/tts_service.dart';

const Color _azulMarino = Color(0xFF1A2C56);

class WordDetailHeader extends StatelessWidget {
  final String displayLemma;
  final List<String> allPosLabels;
  final String? ipa;
  final String currentWord;
  final bool isDark;

  const WordDetailHeader({
    super.key,
    required this.displayLemma,
    required this.allPosLabels,
    this.ipa,
    required this.currentWord,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Lema Principal ────────────────────────────────────────────────
        Text(
          displayLemma,
          style: TextStyle(
            fontFamily: 'Playfair',
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFF8FAFC) : _azulMarino,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),

        // ── Categoría gramatical & Fonética IPA ───────────────────────────
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            if (allPosLabels.isNotEmpty)
              Text(
                allPosLabels.join(' · '),
                style: TextStyle(
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF64748B),
                ),
              ),
            if (ipa != null && ipa!.isNotEmpty) ...[
              if (allPosLabels.isNotEmpty)
                Text(
                  '·',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    fontSize: 16,
                  ),
                ),
              ValueListenableBuilder<bool>(
                valueListenable: TtsService.instance.isSpeakingNotifier,
                builder: (context, isSpeaking, _) {
                  return InkWell(
                    onTap: () {
                      if (isSpeaking) {
                        TtsService.instance.stop();
                      } else {
                        TtsService.instance.speak(currentWord);
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSpeaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                            size: 18,
                            color: isSpeaking
                                ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '/$ipa/',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: isSpeaking ? FontWeight.bold : FontWeight.normal,
                              color: isSpeaking
                                  ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              // Si no tiene transcripción IPA, botón sutil de pronunciación
              ValueListenableBuilder<bool>(
                valueListenable: TtsService.instance.isSpeakingNotifier,
                builder: (context, isSpeaking, _) {
                  return InkWell(
                    onTap: () {
                      if (isSpeaking) {
                        TtsService.instance.stop();
                      } else {
                        TtsService.instance.speak(currentWord);
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSpeaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                            size: 17,
                            color: isSpeaking
                                ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pronunciar',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontStyle: FontStyle.italic,
                              color: isSpeaking
                                  ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
