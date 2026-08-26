import 'package:flutter/material.dart';

class HistoryBottomBar extends StatelessWidget {
  final List<Map<String, dynamic>> historyStack;
  final int historyIndex;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool isDark;

  const HistoryBottomBar({
    super.key,
    required this.historyStack,
    required this.historyIndex,
    required this.onBack,
    required this.onForward,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final String backLabel = historyIndex > 0
        ? historyStack[historyIndex - 1]['word'] as String
        : 'Atrás';
    final bool canGoForward = historyIndex < historyStack.length - 1;
    final String forwardLabel = canGoForward
        ? historyStack[historyIndex + 1]['word'] as String
        : '';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFF8B1A1A), // Carmesí estilo RAE
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Retroceder
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          backLabel,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón Adelantar
              if (canGoForward)
                InkWell(
                  onTap: onForward,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            forwardLabel,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 32),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
