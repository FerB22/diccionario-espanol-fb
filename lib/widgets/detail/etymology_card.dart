import 'package:flutter/material.dart';

class EtymologyCard extends StatelessWidget {
  final String etymology;
  final bool isDark;

  const EtymologyCard({
    super.key,
    required this.etymology,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (etymology.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECEEF1),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          border: Border(
            left: BorderSide(
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1A2C56),
              width: 4.5,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 9, 18, 9),
        child: Text(
          etymology,
          style: TextStyle(
            fontFamily: 'Playfair',
            fontStyle: FontStyle.italic,
            fontSize: 16.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B6A38), // Verde RAE
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
