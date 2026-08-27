import 'package:flutter/material.dart';

const Color _dorado = Color(0xFFF0A500);

class DidYouKnowCard extends StatelessWidget {
  final String factText;
  final bool isDark;

  const DidYouKnowCard({
    super.key,
    required this.factText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (factText.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: isDark ? 1 : 2,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 14),
              child: Icon(
                Icons.history_edu_rounded,
                color: _dorado,
                size: 32,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Sabías que...?',
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF0A500) : const Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    factText,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14,
                      height: 1.45,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 42,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _dorado.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
