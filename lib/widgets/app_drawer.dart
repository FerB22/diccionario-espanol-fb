import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../providers/app_provider.dart';
import '../screens/favorites_screen.dart';
import '../screens/help_screen.dart';
import '../screens/history_screen.dart';
import '../screens/word_detail_screen.dart';

const List<double> _scales       = [0.85, 1.0, 1.15, 1.3];
const List<double> _displaySizes  = [12.0, 15.0, 18.0, 22.0];

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      child: Column(
        children: [
          // ── Header con SafeArea para que nunca colisione con el notch/status bar ──
          Container(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1A2C56),
            width: double.infinity,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DrawerHeaderBtn(
                      icon: Icons.home_rounded,
                      label: 'Inicio',
                      onTap: () => Navigator.pop(context),
                    ),
                    _DrawerHeaderBtn(
                      icon: Icons.history_rounded,
                      label: 'Historial',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          _appRoute(const HistoryScreen()),
                        );
                      },
                    ),
                    _DrawerHeaderBtn(
                      icon: Icons.star_rounded,
                      label: 'Favoritos',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          _appRoute(const FavoritesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Selector de tamaño de fuente ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tamaño de texto',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF1A2C56),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (int i = 0; i < _scales.length; i++) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => provider.setFontSize(_scales[i]),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: provider.fontSize == _scales[i]
                                  ? (isDark ? const Color(0xFFF0A500) : const Color(0xFF1A2C56))
                                  : (isDark ? const Color(0xFF1F2937) : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: provider.fontSize == _scales[i]
                                    ? (isDark ? const Color(0xFFF0A500) : const Color(0xFF1A2C56))
                                    : (isDark ? const Color(0xFF374151) : Colors.grey.shade300),
                                width: provider.fontSize == _scales[i] ? 1.8 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'A',
                                style: TextStyle(
                                  fontSize: _displaySizes[i],
                                  color: provider.fontSize == _scales[i]
                                      ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                      : (isDark ? Colors.white : Colors.black87),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // ── Modo oscuro ──────────────────────────────────────────────────────
          SwitchListTile(
            secondary: Icon(
              Icons.dark_mode_outlined,
              color: isDark ? const Color(0xFFF0A500) : const Color(0xFF1A2C56),
            ),
            title: Text(
              'Modo oscuro',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            value: provider.isDarkMode,
            activeColor: const Color(0xFFF0A500),
            onChanged: (_) => provider.toggleDarkMode(),
          ),

          const Divider(height: 24),

          // ── Palabra del día ──────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Color(0xFFF0A500)),
            title: Text(
              'Palabra del día',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              final word = await DatabaseHelper().getRandomWord();
              if (word != null && context.mounted) {
                Navigator.push(
                  context,
                  _appRoute(WordDetailScreen(
                    wordId: word.id,
                    word: word.word,
                  )),
                );
              }
            },
          ),

          // ── Ayuda ────────────────────────────────────────────────────────────
          ListTile(
            leading: Icon(
              Icons.help_outline_rounded,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1A2C56),
            ),
            title: Text(
              'Ayuda y funciones',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                _appRoute(const HelpScreen()),
              );
            },
          ),

          const Spacer(),

          // ── Footer ───────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Diccionario Español FB\nBasado en Wikcionario (CC BY-SA 3.0)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeaderBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerHeaderBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Route<T> _appRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: const Cubic(0.23, 1.0, 0.32, 1.0),
        reverseCurve: Curves.easeInCubic,
      );
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0.06, 0.0),
        end: Offset.zero,
      ).animate(curve);

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      );
    },
  );
}