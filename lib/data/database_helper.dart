import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/search_result.dart';
import '../models/verb_conjugation.dart';

/// Singleton que gestiona toda la interacción con la base de datos SQLite.
class DatabaseHelper {
  // ── Singleton ──────────────────────────────────────────────────────────────
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _database;
  int? _maxWordId;

  /// Devuelve la instancia abierta de la BD, inicializándola si es necesario.
  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  // ── Inicialización ────────────────────────────────────────────────────────

  /// Normaliza una cadena removiendo tildes para búsqueda flexible
  static String normalize(String s) {
    const accents = 'áéíóúüÁÉÍÓÚÜ';
    const noAccents = 'aeiouuAEIOUU';
    var result = s.toLowerCase().trim();
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], noAccents[i]);
    }
    return result;
  }

  /// Copia el asset 'assets/diccionario.db' al directorio de documentos del
  /// dispositivo y abre la conexión SQLite con optimizaciones.
  Future<Database> _initDb() async {
    final Directory docsDir = await getApplicationDocumentsDirectory();
    final String dbPath = p.join(docsDir.path, 'diccionario.db');
    final File dbFile = File(dbPath);

    final prefs = await SharedPreferences.getInstance();
    const currentDbVersion = 17;
    final savedVersion = prefs.getInt('db_version') ?? 0;

    if (savedVersion < currentDbVersion || !await dbFile.exists() || await dbFile.length() < 10000000) {
      if (await dbFile.exists()) {
        try {
          await dbFile.delete();
        } catch (_) {}
      }
      try {
        final ByteData data = await rootBundle.load('assets/diccionario.db.gz');
        final List<int> compressedBytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        final List<int> decompressedBytes = gzip.decode(compressedBytes);
        await dbFile.writeAsBytes(decompressedBytes, flush: true);
      } catch (_) {
        final ByteData data = await rootBundle.load('assets/diccionario.db');
        final List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await dbFile.writeAsBytes(bytes, flush: true);
      }
      await prefs.setInt('db_version', currentDbVersion);
    }

    return openDatabase(
      dbPath,
      readOnly: false,
      onOpen: (db) async {
        await _createLocalTables(db);
      },
    );
  }

  /// Crea las tablas locales (historial y favoritos) si no existen.
  Future<void> _createLocalTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS historial (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        palabra_id INTEGER NOT NULL,
        word       TEXT    NOT NULL,
        fecha      TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS favoritos (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        palabra_id INTEGER NOT NULL UNIQUE,
        word       TEXT    NOT NULL,
        fecha      TEXT    NOT NULL
      )
    ''');
  }

  // ── Búsqueda ──────────────────────────────────────────────────────────────

  /// Busca palabras según el [mode] de búsqueda con soporte de tildes.
  Future<List<SearchResult>> searchWords(
    String query,
    String mode, {
    int limit = 30,
  }) async {
    final db = await database;
    final String q = query.trim();
    if (q.isEmpty) return [];

    final String qNorm = normalize(q);
    final String qLower = q.toLowerCase();

    List<Map<String, dynamic>> rows;

    final int fetchLimit = (mode == 'exacta' || mode == 'aleatoria') ? limit : limit * 3;

    switch (mode) {
      case 'exacta':
        rows = await db.rawQuery(
          '''SELECT id, word, pos, pos_label FROM palabras 
             WHERE word_lower = ? OR word_norm = ? 
             ORDER BY CASE WHEN word_lower = ? THEN 0 ELSE 1 END
             LIMIT ?''',
          [qLower, qNorm, qLower, fetchLimit],
        );

      case 'comienza':
        rows = await db.rawQuery(
          '''SELECT id, word, pos, pos_label FROM palabras 
             WHERE word_norm LIKE ? OR word_lower LIKE ?
             ORDER BY CASE WHEN word_norm = ? THEN 0 ELSE 1 END, length(word) ASC
             LIMIT ?''',
          ['$qNorm%', '$qLower%', qNorm, fetchLimit],
        );

      case 'termina':
        rows = await db.rawQuery(
          '''SELECT id, word, pos, pos_label FROM palabras 
             WHERE word_norm LIKE ? OR word_lower LIKE ?
             ORDER BY length(word) ASC
             LIMIT ?''',
          ['%$qNorm', '%$qLower', fetchLimit],
        );

      case 'contiene':
        rows = await db.rawQuery(
          '''SELECT id, word, pos, pos_label FROM palabras 
             WHERE word_norm LIKE ? OR word_lower LIKE ?
             ORDER BY CASE WHEN word_norm LIKE ? THEN 0 ELSE 1 END, length(word) ASC
             LIMIT ?''',
          ['%$qNorm%', '%$qLower%', '$qNorm%', fetchLimit],
        );

      case 'anagrama':
        final String sorted = _sortLetters(qNorm);
        rows = await db.rawQuery(
          'SELECT id, word, pos, pos_label FROM palabras '
          'WHERE word_sorted = ? LIMIT ?',
          [sorted, fetchLimit],
        );

      case 'expresion':
        rows = await db.rawQuery(
          '''SELECT MIN(COALESCE(p.id, e.headword_id, e.id)) AS id, 
                    e.expression AS word, 
                    'locución' AS pos, 
                    COALESCE(e.pos_label, 'locución') AS pos_label
             FROM expressions e
             LEFT JOIN palabras p ON (p.word_lower = e.headword OR p.id = e.headword_id)
             WHERE e.expression_lower LIKE ? OR e.expression LIKE ?
             GROUP BY e.expression
             ORDER BY length(e.expression) ASC
             LIMIT ?''',
          ['%$qLower%', '%$qNorm%', fetchLimit],
        );

      case 'aleatoria':
        final randomWord = await getRandomWord();
        return randomWord != null ? [randomWord] : [];

      default:
        rows = await db.rawQuery(
          '''SELECT id, word, pos, pos_label FROM palabras 
             WHERE word_norm LIKE ? OR word_lower LIKE ?
             ORDER BY CASE WHEN word_norm = ? THEN 0 ELSE 1 END, length(word) ASC
             LIMIT ?''',
          ['$qNorm%', '$qLower%', qNorm, fetchLimit],
        );
    }

    // Deduplica resultados por palabra única y combina categorías gramaticales
    final Map<String, SearchResult> seen = {};
    for (final row in rows) {
      final w = (row['word'] as String?) ?? '';
      final wKey = w.toLowerCase().trim();
      final posLabel = (row['pos_label'] as String?) ?? '';

      if (!seen.containsKey(wKey)) {
        seen[wKey] = SearchResult.fromMap(row);
      } else {
        final existing = seen[wKey]!;
        if (posLabel.isNotEmpty && !existing.posLabel.contains(posLabel)) {
          final mergedLabel = existing.posLabel.isNotEmpty
              ? '${existing.posLabel}, $posLabel'
              : posLabel;
          seen[wKey] = SearchResult(
            id: existing.id,
            word: existing.word,
            pos: existing.pos,
            posLabel: mergedLabel,
          );
        }
      }

      if (seen.length >= limit) break;
    }

    return seen.values.toList();
  }

  /// Busca una palabra por lema exacto o normalizado para salto hipertextual,
  /// incluyendo resolución de formas conjugadas y desclitización defensiva en 2 pasos.
  Future<SearchResult?> findWord(String text, {String? currentWord}) async {
    final clean = text.trim();
    if (clean.isEmpty) return null;
    final cleanNorm = normalize(clean);
    final cleanLower = clean.toLowerCase();
    final currentLower = currentWord?.toLowerCase().trim();

    final db = await database;
    // 1. Coincidencia exacta o normalizada en el lema
    final exact = await db.rawQuery(
      '''SELECT id, word, pos, pos_label FROM palabras 
         WHERE word_lower = ? OR word_norm = ? 
         ORDER BY CASE WHEN word_lower = ? THEN 0 ELSE 1 END 
         LIMIT 1''',
      [cleanLower, cleanNorm, cleanLower],
    );
    if (exact.isNotEmpty) {
      final res = SearchResult.fromMap(exact.first);
      if (currentLower != null && res.word.toLowerCase() == currentLower) {
        return null;
      }
      return res;
    }

    // 2. Búsqueda indexada en la tabla de conjugaciones (formas verbales simples)
    final conjRes = await db.rawQuery(
      '''SELECT p.id, p.word, p.pos, p.pos_label 
         FROM verb_forms vf
         JOIN palabras p ON vf.palabra_id = p.id
         WHERE vf.form = ?
         LIMIT 1''',
      [cleanLower],
    );
    if (conjRes.isNotEmpty) {
      final res = SearchResult.fromMap(conjRes.first);
      if (currentLower == null || res.word.toLowerCase() != currentLower) {
        return res;
      }
    }

    // 3. Desmontaje defensivo de clíticos en 2 pasos (ej. lavarse, peinarse, cantándolo)
    const cliticSuffixes = [
      'selo', 'sela', 'selos', 'selas',
      'melo', 'mela', 'melos', 'melas',
      'telo', 'tela', 'telos', 'telas',
      'noslo', 'nosla', 'noslos', 'noslas',
      'se', 'me', 'te', 'le', 'la', 'les', 'las', 'lo', 'los', 'nos', 'os'
    ];

    for (final suf in cliticSuffixes) {
      if (cleanLower.endsWith(suf) && cleanLower.length > suf.length + 2) {
        final baseCand = cleanLower.substring(0, cleanLower.length - suf.length);
        // Paso 2: Verificar si la raíz base existe como verbo en palabras
        final vCheck = await db.rawQuery(
          '''SELECT id, word, pos, pos_label FROM palabras 
             WHERE (word_lower = ? OR word_norm = ?)
               AND (pos = 'verb' OR pos_label LIKE '%verbo%')
             LIMIT 1''',
          [baseCand, normalize(baseCand)],
        );
        if (vCheck.isNotEmpty) {
          final res = SearchResult.fromMap(vCheck.first);
          if (currentLower == null || res.word.toLowerCase() != currentLower) {
            return res;
          }
        }
      }
    }

    // 4. Probar derivaciones nominales simples (plural a singular, femenino)
    final candidates = <String>[];
    if (cleanLower.endsWith('s') && cleanLower.length > 2) {
      candidates.add(cleanLower.substring(0, cleanLower.length - 1));
    }
    if (cleanLower.endsWith('es') && cleanLower.length > 3) {
      candidates.add(cleanLower.substring(0, cleanLower.length - 2));
    }
    if (cleanLower.endsWith('o') && cleanLower.length > 2) {
      candidates.add('${cleanLower.substring(0, cleanLower.length - 1)}a');
    }

    for (final cand in candidates) {
      final candRes = await db.rawQuery(
        '''SELECT id, word, pos, pos_label FROM palabras 
           WHERE word_lower = ? OR word_norm = ? 
           LIMIT 1''',
        [cand, normalize(cand)],
      );
      if (candRes.isNotEmpty) {
        final res = SearchResult.fromMap(candRes.first);
        if (currentLower == null || res.word.toLowerCase() != currentLower) {
          return res;
        }
      }
    }

    // 5. Coincidencia por prefijo (descartando la palabra actual)
    final prefix = await db.rawQuery(
      '''SELECT id, word, pos, pos_label FROM palabras 
         WHERE (word_norm LIKE ? OR word_lower LIKE ?)
           AND word_lower != ?
         ORDER BY length(word) ASC 
         LIMIT 1''',
      ['$cleanNorm%', '$cleanLower%', currentLower ?? ''],
    );
    if (prefix.isNotEmpty) {
      return SearchResult.fromMap(prefix.first);
    }

    return null;
  }

  /// Ordena las letras de [s] para búsqueda por anagrama.
  String _sortLetters(String s) {
    final chars = normalize(s).split('')..sort();
    return chars.join();
  }

  // ── Detalle de palabra ────────────────────────────────────────────────────

  /// Retorna la información completa de una palabra: datos base, acepciones de
  /// todas las categorías gramaticales asociadas, pronunciación (IPA), sinónimos y antónimos.
  Future<Map<String, dynamic>> getWordDetail(int id) async {
    final db = await database;

    // Datos base de la palabra
    final List<Map<String, dynamic>> wordRows = await db.rawQuery(
      'SELECT * FROM palabras WHERE id = ?',
      [id],
    );
    if (wordRows.isEmpty) return {};
    final baseWord = wordRows.first;
    final wordLower = (baseWord['word_lower'] as String?) ?? (baseWord['word'] as String).toLowerCase();

    // Acepciones / senses de TODAS las entradas homógrafas de la palabra
    final List<Map<String, dynamic>> senses = await db.rawQuery(
      '''SELECT s.*, p.pos_label, p.pos 
         FROM senses s 
         JOIN palabras p ON s.palabra_id = p.id 
         WHERE p.word_lower = ? 
         ORDER BY p.id, s.order_num''',
      [wordLower],
    );

    // Pronunciación IPA (de todas las entradas de la palabra)
    final List<Map<String, dynamic>> sounds = await db.rawQuery(
      '''SELECT DISTINCT ipa FROM sounds 
         WHERE palabra_id IN (SELECT id FROM palabras WHERE word_lower = ?)
         LIMIT 5''',
      [wordLower],
    );

    // Sinónimos por entrada/acepción
    final List<Map<String, dynamic>> senseSynonymsRows = await db.rawQuery(
      '''SELECT s.palabra_id, MIN(COALESCE(p2.id, 0)) as id, s.word
         FROM synonyms s
         JOIN palabras p ON s.palabra_id = p.id
         LEFT JOIN palabras p2 ON p2.word_lower = lower(s.word)
         WHERE p.word_lower = ?
         GROUP BY s.palabra_id, lower(s.word)
         ORDER BY s.word COLLATE NOCASE''',
      [wordLower],
    );

    // Antónimos por entrada/acepción
    final List<Map<String, dynamic>> senseAntonymsRows = await db.rawQuery(
      '''SELECT a.palabra_id, MIN(COALESCE(p2.id, 0)) as id, a.word
         FROM antonyms a
         JOIN palabras p ON a.palabra_id = p.id
         LEFT JOIN palabras p2 ON p2.word_lower = lower(a.word)
         WHERE p.word_lower = ?
         GROUP BY a.palabra_id, lower(a.word)
         ORDER BY a.word COLLATE NOCASE''',
      [wordLower],
    );

    final Map<int, List<SearchResult>> entrySynonyms = {};
    for (final r in senseSynonymsRows) {
      final pid = r['palabra_id'] as int;
      entrySynonyms.putIfAbsent(pid, () => []).add(SearchResult.fromMap(r));
    }

    final Map<int, List<SearchResult>> entryAntonyms = {};
    for (final r in senseAntonymsRows) {
      final pid = r['palabra_id'] as int;
      entryAntonyms.putIfAbsent(pid, () => []).add(SearchResult.fromMap(r));
    }

    // ── Resolución de lema base si es una forma flexiva (Estilo RAE) ─────────
    final List<Map<String, dynamic>> combinedSenses = List.from(senses);
    final formRegex = RegExp(
      r'Forma del (?:femenino|masculino|plural|singular|femenino plural|femenino singular|masculino plural) de ([a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+)',
      caseSensitive: false,
    );

    String? resolvedBaseWord;
    for (final s in senses) {
      final gloss = (s['gloss'] as String?) ?? '';
      final match = formRegex.firstMatch(gloss);
      if (match != null) {
        final target = match.group(1)?.toLowerCase().trim();
        if (target != null && target != wordLower && resolvedBaseWord == null) {
          resolvedBaseWord = target;
        }
      }
    }

    if (resolvedBaseWord != null) {
      final List<Map<String, dynamic>> baseSenses = await db.rawQuery(
        '''SELECT s.*, p.pos_label, p.pos 
           FROM senses s 
           JOIN palabras p ON s.palabra_id = p.id 
           WHERE p.word_lower = ? 
           ORDER BY p.id, s.order_num''',
        [resolvedBaseWord],
      );

      for (final bs in baseSenses) {
        final bg = (bs['gloss'] as String?) ?? '';
        if (!bg.toLowerCase().startsWith('forma del') && !bg.toLowerCase().startsWith('forma de')) {
          combinedSenses.add(bs);
        }
      }

      // Traer sinónimos del lema base
      final List<Map<String, dynamic>> baseSynRows = await db.rawQuery(
        '''SELECT s.palabra_id, MIN(COALESCE(p2.id, 0)) as id, s.word
           FROM synonyms s
           JOIN palabras p ON s.palabra_id = p.id
           LEFT JOIN palabras p2 ON p2.word_lower = lower(s.word)
           WHERE p.word_lower = ?
           GROUP BY s.palabra_id, lower(s.word)
           ORDER BY s.word COLLATE NOCASE''',
        [resolvedBaseWord],
      );
      for (final r in baseSynRows) {
        final pid = r['palabra_id'] as int;
        entrySynonyms.putIfAbsent(pid, () => []).add(SearchResult.fromMap(r));
      }

      // Traer antónimos del lema base
      final List<Map<String, dynamic>> baseAntRows = await db.rawQuery(
        '''SELECT a.palabra_id, MIN(COALESCE(p2.id, 0)) as id, a.word
           FROM antonyms a
           JOIN palabras p ON a.palabra_id = p.id
           LEFT JOIN palabras p2 ON p2.word_lower = lower(a.word)
           WHERE p.word_lower = ?
           GROUP BY a.palabra_id, lower(a.word)
           ORDER BY a.word COLLATE NOCASE''',
        [resolvedBaseWord],
      );
      for (final r in baseAntRows) {
        final pid = r['palabra_id'] as int;
        entryAntonyms.putIfAbsent(pid, () => []).add(SearchResult.fromMap(r));
      }
    }

    final List<SearchResult> allSynonyms = [];
    final Set<String> seenSynonyms = {};
    for (final list in entrySynonyms.values) {
      for (final s in list) {
        if (seenSynonyms.add(s.word.toLowerCase())) {
          allSynonyms.add(s);
        }
      }
    }
    allSynonyms.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));

    final List<SearchResult> allAntonyms = [];
    final Set<String> seenAntonyms = {};
    for (final list in entryAntonyms.values) {
      for (final a in list) {
        if (seenAntonyms.add(a.word.toLowerCase())) {
          allAntonyms.add(a);
        }
      }
    }
    allAntonyms.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));

    // ── Etimología (Estilo RAE) ─────────────────────────────────────────────
    final List<Map<String, dynamic>> etymRows = await db.rawQuery(
      '''SELECT text FROM etymologies 
         WHERE palabra_id IN (SELECT id FROM palabras WHERE word_lower = ?)
         LIMIT 1''',
      [wordLower],
    );
    String? etymology = etymRows.isNotEmpty ? (etymRows.first['text'] as String?) : null;
    if (etymology == null && resolvedBaseWord != null) {
      final List<Map<String, dynamic>> baseEtymRows = await db.rawQuery(
        '''SELECT text FROM etymologies 
           WHERE palabra_id IN (SELECT id FROM palabras WHERE word_lower = ?)
           LIMIT 1''',
        [resolvedBaseWord],
      );
      if (baseEtymRows.isNotEmpty) {
        etymology = baseEtymRows.first['text'] as String?;
      }
    }

    // ── Parónimos / Dudas Frecuentes ─────────────────────────────────────────
    final List<Map<String, dynamic>> paronimoRows = await db.rawQuery(
      '''SELECT explanation FROM paronimos 
         WHERE word_lower = ? 
         LIMIT 1''',
      [wordLower],
    );
    String? paronimo = paronimoRows.isNotEmpty ? (paronimoRows.first['explanation'] as String?) : null;
    if (paronimo == null && resolvedBaseWord != null) {
      final List<Map<String, dynamic>> baseParonimoRows = await db.rawQuery(
        '''SELECT explanation FROM paronimos 
           WHERE word_lower = ? 
           LIMIT 1''',
        [resolvedBaseWord],
      );
      if (baseParonimoRows.isNotEmpty) {
        paronimo = baseParonimoRows.first['explanation'] as String?;
      }
    }

    // ── Expresiones y Locuciones (Estilo RAE) ─────────────────────────────────
    final List<Map<String, dynamic>> expressionRows = await db.rawQuery(
      '''SELECT expression, pos_label, order_num, gloss, raw_tags 
         FROM expressions 
         WHERE headword = ? OR headword_id = ?
         ORDER BY id ASC''',
      [wordLower, id],
    );

    final Map<String, List<Map<String, dynamic>>> groupedExprMap = {};
    for (final row in expressionRows) {
      final exprName = row['expression'] as String;
      groupedExprMap.putIfAbsent(exprName, () => []).add(row);
    }

    final List<Map<String, dynamic>> expressions = groupedExprMap.entries.map((e) {
      return {
        'expression': e.key,
        'senses': e.value,
      };
    }).toList();

    return {
      'word':          baseWord,
      'senses':        combinedSenses,
      'sounds':        sounds,
      'synonyms':      allSynonyms,
      'antonyms':      allAntonyms,
      'entrySynonyms': entrySynonyms,
      'entryAntonyms': entryAntonyms,
      'etymology':     etymology,
      'paronimo':      paronimo,
      'expressions':   expressions,
    };
  }

  // ── Historial ─────────────────────────────────────────────────────────────

  /// Inserta una entrada en el historial; mantiene un máximo de 100 registros.
  Future<void> addToHistory(int palabraId, String word) async {
    final db = await database;
    final String now = DateTime.now().toIso8601String();

    // Si ya existe, elimina la entrada previa para actualizarla al frente
    await db.delete(
      'historial',
      where: 'palabra_id = ?',
      whereArgs: [palabraId],
    );

    await db.insert('historial', {
      'palabra_id': palabraId,
      'word':       word,
      'fecha':      now,
    });

    // Purga entradas más antiguas si supera el límite
    await db.execute('''
      DELETE FROM historial
      WHERE id NOT IN (
        SELECT id FROM historial ORDER BY fecha DESC LIMIT 100
      )
    ''');
  }

  /// Devuelve el historial ordenado del más reciente al más antiguo.
  Future<List<SearchResult>> getHistory() async {
    final db = await database;
    final rows = await db.rawQuery(
      '''SELECT h.palabra_id AS id, h.word,
                p.pos, p.pos_label
         FROM historial h
         LEFT JOIN palabras p ON h.palabra_id = p.id
         ORDER BY h.fecha DESC''',
    );
    return rows.map(SearchResult.fromMap).toList();
  }

  /// Borra todo el historial.
  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('historial');
  }

  /// Elimina una entrada puntual del historial.
  Future<void> removeFromHistory(int palabraId) async {
    final db = await database;
    await db.delete(
      'historial',
      where: 'palabra_id = ?',
      whereArgs: [palabraId],
    );
  }

  // ── Favoritos ─────────────────────────────────────────────────────────────

  /// Agrega una palabra a favoritos (ignora si ya existe).
  Future<void> addToFavorites(int palabraId, String word) async {
    final db = await database;
    await db.insert(
      'favoritos',
      {
        'palabra_id': palabraId,
        'word':       word,
        'fecha':      DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Elimina una palabra de favoritos.
  Future<void> removeFromFavorites(int palabraId) async {
    final db = await database;
    await db.delete(
      'favoritos',
      where: 'palabra_id = ?',
      whereArgs: [palabraId],
    );
  }

  /// Comprueba si una palabra está en favoritos.
  Future<bool> isFavorite(int palabraId) async {
    final db = await database;
    final rows = await db.query(
      'favoritos',
      columns: ['id'],
      where: 'palabra_id = ?',
      whereArgs: [palabraId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Devuelve todos los favoritos ordenados por fecha de adición (más reciente primero).
  Future<List<SearchResult>> getFavorites() async {
    final db = await database;
    final rows = await db.rawQuery(
      '''SELECT f.palabra_id AS id, f.word,
                p.pos, p.pos_label
         FROM favoritos f
         LEFT JOIN palabras p ON f.palabra_id = p.id
         ORDER BY f.fecha DESC''',
    );
    return rows.map(SearchResult.fromMap).toList();
  }

  // ── Palabra aleatoria (Optimizado O(1)) ─────────────────────────────────
  /// Devuelve una palabra aleatoria de la BD principal en <1ms usando el índice primario.
  Future<SearchResult?> getRandomWord() async {
    try {
      final db = await database;
      if (_maxWordId == null) {
        final res = await db.rawQuery('SELECT MAX(id) as max_id FROM palabras');
        if (res.isNotEmpty && res.first['max_id'] != null) {
          _maxWordId = res.first['max_id'] as int;
        } else {
          _maxWordId = 854000;
        }
      }
      final int randomId = (math.Random().nextDouble() * _maxWordId!).toInt() + 1;
      final rows = await db.rawQuery(
        '''SELECT p.id, p.word, p.pos, p.pos_label 
           FROM palabras p 
           JOIN senses s ON s.palabra_id = p.id
           WHERE p.id >= ? 
             AND length(p.word) >= 4
             AND s.gloss NOT LIKE 'Forma del%' 
             AND s.gloss NOT LIKE 'Forma de%'
             AND s.gloss NOT LIKE '%persona del%'
             AND p.pos IN ('noun', 'adj', 'verb')
           LIMIT 1''',
        [randomId],
      );
      if (rows.isNotEmpty) {
        return SearchResult.fromMap(rows.first);
      }

      final fallback = await db.rawQuery(
        "SELECT id, word, pos, pos_label FROM palabras WHERE id >= ? AND length(word) >= 4 LIMIT 1",
        [randomId],
      );
      if (fallback.isNotEmpty) {
        return SearchResult.fromMap(fallback.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── Búsqueda por definición (FTS5) ────────────────────────────────────────

  /// Busca dentro de las definiciones usando la tabla FTS5 `senses_fts`.
  Future<List<SearchResult>> searchByDefinition(String query) async {
    final db = await database;
    // Escapar comillas dobles para FTS5
    final String safeQuery = query.replaceAll('"', '""');
    final rows = await db.rawQuery(
      '''SELECT p.id, p.word, p.pos, p.pos_label
         FROM senses_fts
         JOIN palabras p ON senses_fts.palabra_id = p.id
         WHERE senses_fts MATCH ?
         LIMIT 30''',
      [safeQuery],
    );
    return rows.map(SearchResult.fromMap).toList();
  }

  // ── Conjugación Verbal (Modelo RAE) ───────────────────────────────────────

  /// Obtiene la conjugación completa de un verbo según el modelo oficial de la RAE.
  Future<VerbConjugation?> getConjugation(int palabraId, String word) async {
    final db = await database;
    final cleanWord = word.trim().toLowerCase();

    final rows = await db.rawQuery(
      '''SELECT data
         FROM conjugations
         WHERE palabra_id = ? OR verb = ?
         LIMIT 1''',
      [palabraId, cleanWord],
    );

    if (rows.isEmpty) return null;
    final dataStr = rows.first['data'] as String?;
    if (dataStr == null || dataStr.isEmpty) return null;

    try {
      final rawList = jsonDecode(dataStr) as List;
      final parsedRows = rawList.map((item) {
        final list = item as List;
        return {
          'mood': list.isNotEmpty ? list[0] : '',
          'tense': list.length > 1 ? list[1] : '',
          'person': list.length > 2 ? list[2] : null,
          'number': list.length > 3 ? list[3] : null,
          'form': list.length > 4 ? list[4] : '',
          'variant': list.length > 5 ? list[5] : 'standard',
        };
      }).toList();

      return VerbConjugation.fromDbRows(
        palabraId: palabraId,
        verb: word.trim(),
        rows: parsedRows,
      );
    } catch (_) {
      return null;
    }
  }

  /// Comprueba rápidamente si una palabra dispone de tabla de conjugación.
  Future<bool> hasConjugation(int palabraId, String word) async {
    final db = await database;
    final cleanWord = word.trim().toLowerCase();

    final rows = await db.rawQuery(
      'SELECT palabra_id FROM conjugations WHERE palabra_id = ? OR verb = ? LIMIT 1',
      [palabraId, cleanWord],
    );
    return rows.isNotEmpty;
  }

  // ── Cierre ────────────────────────────────────────────────────────────────

  /// Cierra la conexión con la base de datos (útil en tests).
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}