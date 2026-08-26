import 'package:flutter/material.dart';

const Color _azulMarino = Color(0xFF1A2C56);
const Color _dorado     = Color(0xFFF0A500);

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : _azulMarino,
        foregroundColor: Colors.white,
        title: const Text(
          'Ayuda y Funciones',
          style: TextStyle(
            fontFamily: 'Playfair',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF1E293B) : _azulMarino.withOpacity(0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? const Color(0xFF334155) : _azulMarino.withOpacity(0.12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    color: isDark ? _dorado : _azulMarino,
                    size: 36,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Diccionario con más de 247,000 palabras y formas léxicas. Funciona 100 % sin conexión a internet.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white : _azulMarino,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Modos de Búsqueda',
            style: TextStyle(
              fontFamily: 'Playfair',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF0A500) : _azulMarino,
            ),
          ),
          const SizedBox(height: 14),
          _buildHelpItem(
            icon: Icons.search,
            color: const Color(0xFFF0A500),
            title: 'PALABRA',
            desc: 'Búsqueda estándar. Muestra sugerencias de palabras que comienzan con las letras escritas.',
            isDark: isDark,
          ),
          _buildHelpItem(
            icon: Icons.chat_bubble_outline,
            color: const Color(0xFFFF8C00),
            title: 'EXPRESIONES',
            desc: 'Busca locuciones, modismos y frases compuestas de uso común.',
            isDark: isDark,
          ),
          _buildHelpItem(
            icon: Icons.filter_center_focus,
            color: const Color(0xFFD32F2F),
            title: 'EXACTA',
            desc: 'Busca únicamente la palabra tal cual la escribiste, sin autocompletar.',
            isDark: isDark,
          ),
          _buildHelpItem(
            icon: Icons.arrow_forward,
            color: const Color(0xFF388E3C),
            title: 'COMIENZA POR...',
            desc: 'Encuentra todas las palabras que inician con un prefijo específico.',
            isDark: isDark,
          ),
          _buildHelpItem(
            icon: Icons.arrow_back,
            color: const Color(0xFF7B1FA2),
            title: 'TERMINA EN...',
            desc: 'Ideal para encontrar rimas y palabras con un mismo sufijo.',
            isDark: isDark,
          ),
          _buildHelpItem(
            icon: Icons.format_align_center,
            color: const Color(0xFF1976D2),
            title: 'CONTIENE...',
            desc: 'Busca palabras que contengan las letras introducidas en cualquier posición.',
            isDark: isDark,
          ),
          _buildHelpItem(
            icon: Icons.shuffle,
            color: const Color(0xFF00796B),
            title: 'ANAGRAMAS',
            desc: 'Encuentra palabras formadas reordenando exactamente las mismas letras.',
            isDark: isDark,
          ),
          _buildHelpItem(
            icon: Icons.casino_outlined,
            color: const Color(0xFF9E9E9E),
            title: 'ALEATORIA',
            desc: 'Descubre vocabulario nuevo mostrando una palabra al azar al instante.',
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          Text(
            'Herramientas',
            style: TextStyle(
              fontFamily: 'Playfair',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF0A500) : _azulMarino,
            ),
          ),
          const SizedBox(height: 14),
          _buildHelpItem(
            icon: Icons.star_rounded,
            color: _dorado,
            title: 'Favoritos',
            desc: 'Guarda palabras tocando la estrella para repasarlas y compartirlas cuando quieras.',
            isDark: isDark,
          ),
          _buildHelpItem(
            icon: Icons.history_rounded,
            color: isDark ? const Color(0xFFF87171) : const Color(0xFF8B1A1A),
            title: 'Historial',
            desc: 'Registro automático de todas las definiciones que has consultado.',
            isDark: isDark,
          ),
          _buildHelpItem(
            icon: Icons.format_size_rounded,
            color: isDark ? const Color(0xFF60A5FA) : _azulMarino,
            title: 'Tamaño de texto',
            desc: 'Ajusta el tamaño de la letra con 4 niveles desde el menú lateral para máxima comodidad.',
            isDark: isDark,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static Widget _buildHelpItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}