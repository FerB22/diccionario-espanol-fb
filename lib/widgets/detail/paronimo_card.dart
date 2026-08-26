import 'package:flutter/material.dart';
import '../clickable_span_builder.dart';

class ParonimoCard extends StatelessWidget {
  final String? paronimo;
  final ClickableSpanBuilder spanBuilder;
  final bool isDark;

  const ParonimoCard({
    super.key,
    this.paronimo,
    required this.spanBuilder,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (paronimo == null || paronimo!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFFF0A500).withValues(alpha: 0.5)
                  : const Color(0xFFF59E0B),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 10),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 21,
                  color: isDark ? const Color(0xFFF0A500) : const Color(0xFFB45309),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DUDA FRECUENTE',
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? const Color(0xFFF0A500) : const Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 5),
                    spanBuilder.buildParonimo(text: paronimo!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
