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

    final isObservation = paronimo!.toLowerCase().contains('voz propuesta') ||
        paronimo!.toLowerCase().contains('observación') ||
        paronimo!.toLowerCase().contains('anglicismo');

    final title = isObservation ? 'OBSERVACIÓN LINGÜÍSTICA' : 'DUDA FRECUENTE';
    final icon = isObservation ? Icons.menu_book_rounded : Icons.lightbulb_outline_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEBE3D5), // Fondo beige oscurito
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF475569)
                  : const Color(0xFFD4C5B0),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 10),
                child: Icon(
                  icon,
                  size: 21,
                  color: isDark ? const Color(0xFFF0A500) : const Color(0xFF8C6D3F),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? const Color(0xFFF0A500) : const Color(0xFF78350F),
                      ),
                    ),
                    const SizedBox(height: 6),
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
