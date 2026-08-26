import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/search_result.dart';

const Color _azulMarino = Color(0xFF1A2C56);

/// Constructor de texto interactivo (hipervínculos a palabras del diccionario)
/// con gestión segura del ciclo de vida de los [GestureRecognizer].
class ClickableSpanBuilder {
  final BuildContext context;
  final bool isDark;
  final String currentWord;
  final void Function(int id, String word) onNavigate;
  final T Function<T extends GestureRecognizer>(T recognizer) registerRecognizer;

  const ClickableSpanBuilder({
    required this.context,
    required this.isDark,
    required this.currentWord,
    required this.onNavigate,
    required this.registerRecognizer,
  });

  /// Construye el texto enriquecido de una acepción con palabras clickeables.
  Widget buildGloss({
    required String gloss,
    String? posText,
    List<String> contextTags = const [],
  }) {
    final RegExp tokenRegex = RegExp(r'(\*[^*]+\*|\s+|[.,;:\-—–¿?¡!()\[\]"«»/]+|[^\s*.,;:\-—–¿?¡!()\[\]"«»/]+)');
    final matches = tokenRegex.allMatches(gloss);

    final List<InlineSpan> spans = [];

    // 1. Categoría gramatical (ej. "adj. ")
    if (posText != null && posText.isNotEmpty) {
      spans.add(
        TextSpan(
          text: '$posText ',
          style: TextStyle(
            fontFamily: 'Playfair',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
            height: 1.55,
          ),
        ),
      );
    }

    // 2. Etiquetas de contexto / registro (ej. "Literario, Desusado. ")
    if (contextTags.isNotEmpty) {
      final tagText = '${contextTags.join(", ")}. ';
      spans.add(
        TextSpan(
          text: tagText,
          style: TextStyle(
            fontFamily: 'serif',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            fontSize: 14.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            height: 1.55,
          ),
        ),
      );
    }

    for (final match in matches) {
      final rawToken = match.group(0) ?? '';
      final bool isItalic = rawToken.length >= 2 && rawToken.startsWith('*') && rawToken.endsWith('*');
      final token = isItalic ? rawToken.substring(1, rawToken.length - 1) : rawToken;

      final bool isWord = RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]').hasMatch(token);

      if (isWord) {
        final recognizer = registerRecognizer(
          TapGestureRecognizer()
            ..onTap = () async {
              final cleanWord = token.replaceAll(RegExp(r'[^a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]'), '');
              if (cleanWord.isEmpty) return;

              final result = await DatabaseHelper.instance.findWord(cleanWord, currentWord: currentWord);
              if (result != null && context.mounted) {
                onNavigate(result.id, result.word);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('«$cleanWord» no se encuentra en el diccionario'),
                    duration: const Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: _azulMarino,
                  ),
                );
              }
            },
        );

        spans.add(
          TextSpan(
            text: token,
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              fontSize: 16,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
              height: 1.55,
            ),
            recognizer: recognizer,
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token,
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              fontSize: 16,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
              height: 1.55,
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontFamily: 'serif', fontSize: 16, height: 1.55),
    );
  }

  /// Construye la lista inline de sinónimos o antónimos asociados a una acepción.
  Widget buildInlineSynonyms({
    required String prefix,
    required List<SearchResult> items,
    bool isAntonym = false,
  }) {
    final Color prefixColor = isAntonym
        ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFBE123C))
        : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1));
    final Color wordColor = isAntonym
        ? (isDark ? const Color(0xFFFECDD3) : const Color(0xFF991B1B))
        : (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8));

    final List<InlineSpan> spans = [
      TextSpan(
        text: '$prefix ',
        style: TextStyle(
          fontFamily: 'Playfair',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          fontSize: 14.5,
          color: prefixColor,
        ),
      ),
    ];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      final recognizer = registerRecognizer(
        TapGestureRecognizer()
          ..onTap = () async {
            final result = await DatabaseHelper.instance.findWord(item.word);
            if (result != null && context.mounted) {
              onNavigate(result.id, result.word);
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('«${item.word}» no se encuentra en el diccionario'),
                  duration: const Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: _azulMarino,
                ),
              );
            }
          },
      );

      spans.add(
        TextSpan(
          text: item.word,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 14.5,
            color: wordColor,
            fontWeight: FontWeight.w500,
          ),
          recognizer: recognizer,
        ),
      );

      if (!isLast) {
        spans.add(
          TextSpan(
            text: ', ',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 14.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '.',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 14.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(children: spans),
        style: const TextStyle(fontFamily: 'serif', fontSize: 14.5, height: 1.45),
      ),
    );
  }

  /// Construye el texto interactivo de la tarjeta de Duda Frecuente / Parónimos.
  Widget buildParonimo({required String text}) {
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1F2937);
    final linkColor = isDark ? const Color(0xFFF0A500) : const Color(0xFFB45309);

    final regex = RegExp(r'(\*[^*]+\*|[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+|[^a-zA-ZáéíóúÁÉÍÓÚñÑüÜ*]+)');
    final matches = regex.allMatches(text);
    final List<InlineSpan> spans = [];

    final stopWords = {
      'no', 'confundir', 'con', 'ni', 'del', 'de', 'la', 'el', 'los', 'las',
      'un', 'una', 'unos', 'unas', 'en', 'o', 'y', 'es', 'son', 'se', 'usa',
      'para', 'por', 'que', 'forma', 'verbo', 'sustantivo', 'adjetivo', 'tipo',
      'fruto', 'cerca', 'pieza', 'hueca', 'persona', 'lugar', 'voz', 'propuesta',
      'partir', 'más', 'presente', 'otros', 'términos', 'españoles', 'como',
      'ha', 'formado'
    };

    for (final match in matches) {
      final rawToken = match.group(0) ?? '';
      final bool isItalic = rawToken.length >= 2 && rawToken.startsWith('*') && rawToken.endsWith('*');
      final token = isItalic ? rawToken.substring(1, rawToken.length - 1) : rawToken;

      final bool isWord = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+$').hasMatch(token);

      if (isWord && !stopWords.contains(token.toLowerCase())) {
        final recognizer = registerRecognizer(
          TapGestureRecognizer()
            ..onTap = () async {
              final cleanWord = token.replaceAll(RegExp(r'[^a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]'), '');
              if (cleanWord.isEmpty) return;

              final result = await DatabaseHelper.instance.findWord(cleanWord, currentWord: currentWord);
              if (result != null && context.mounted) {
                onNavigate(result.id, result.word);
              }
            },
        );

        spans.add(
          TextSpan(
            text: token,
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: linkColor,
              decoration: TextDecoration.underline,
              decorationColor: linkColor.withValues(alpha: 0.35),
              height: 1.45,
            ),
            recognizer: recognizer,
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token,
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              fontSize: 14.5,
              color: textColor,
              height: 1.45,
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontFamily: 'serif', fontSize: 14.5, height: 1.45),
    );
  }
}
