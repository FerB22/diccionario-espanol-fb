import 'package:flutter/material.dart';
import '../../models/search_result.dart';

const Color _azulMarino = Color(0xFF1A2C56);
const Color _dorado     = Color(0xFFF0A500);

class WordOfDayCard extends StatelessWidget {
  final SearchResult? word;
  final bool loading;
  final bool isDark;
  final VoidCallback onSelect;

  const WordOfDayCard({
    super.key,
    required this.word,
    required this.loading,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          children: [
            // Encabezado con icono nativo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: _dorado, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Palabra del día',
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: isDark ? _dorado : _azulMarino),
              )
            else if (word != null) ...[
              // Lema en Playfair Display
              Text(
                word!.word,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : _azulMarino,
                  height: 1.1,
                ),
              ),

              // Insignia de categoría gramatical
              if (word!.posLabel.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    word!.posLabel,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Botón cápsula "Ver definición"
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFFF0A500) : _azulMarino,
                  foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                ),
                icon: Icon(
                  Icons.menu_book_rounded,
                  size: 17,
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                ),
                label: Text(
                  'Ver definición',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  ),
                ),
                onPressed: onSelect,
              ),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No disponible'),
              ),
          ],
        ),
      ),
    );
  }
}
