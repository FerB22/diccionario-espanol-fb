/// Representa una fila individual de conjugación en la tabla estilo RAE.
class ConjugationRowItem {
  final String pronoun;
  final String simple;
  final String? compound;

  const ConjugationRowItem({
    required this.pronoun,
    required this.simple,
    this.compound,
  });
}

/// Representa un bloque de tiempo verbal (ej. Presente / Pretérito perfecto compuesto).
class ConjugationTenseBlock {
  final String simpleTitle;
  final String? compoundTitle;
  final List<ConjugationRowItem> rows;

  const ConjugationTenseBlock({
    required this.simpleTitle,
    this.compoundTitle,
    required this.rows,
  });
}

/// Modelo completo de conjugación verbal según el formato oficial de la RAE.
class VerbConjugation {
  final int palabraId;
  final String verb;
  final String infinitive;
  final String infinitiveCompound;
  final String gerund;
  final String gerundCompound;
  final String participle;

  final List<ConjugationTenseBlock> indicativeBlocks;
  final List<ConjugationTenseBlock> subjunctiveBlocks;
  final List<ConjugationRowItem> imperativeRows;

  const VerbConjugation({
    required this.palabraId,
    required this.verb,
    required this.infinitive,
    required this.infinitiveCompound,
    required this.gerund,
    required this.gerundCompound,
    required this.participle,
    required this.indicativeBlocks,
    required this.subjunctiveBlocks,
    required this.imperativeRows,
  });

  /// Construye el modelo RAE combinando las formas simples de la BD y generando
  /// dinámicamente los tiempos compuestos con el auxiliar 'haber'.
  factory VerbConjugation.fromDbRows({
    required int palabraId,
    required String verb,
    required List<Map<String, dynamic>> rows,
  }) {
    String infinitive = verb;
    String gerund = '';
    String participle = '';

    // Index simple forms: (mood, tense, person, number, variant) -> list of strings
    final Map<String, List<String>> formIndex = {};

    for (final r in rows) {
      final mood = (r['mood'] as String?) ?? '';
      final tense = (r['tense'] as String?) ?? '';
      final person = (r['person'] as String?) ?? '';
      final number = (r['number'] as String?) ?? '';
      final variant = (r['variant'] as String?) ?? 'standard';
      final form = (r['form'] as String?) ?? '';

      if (form.isEmpty) continue;

      if (mood == 'impersonal') {
        if (tense == 'infinitive') {
          infinitive = form;
        } else if (tense == 'gerund') {
          gerund = form;
        } else if (tense == 'participle') {
          participle = form;
        }
        continue;
      }

      final key = '$mood|$tense|$person|$number|$variant';
      formIndex.putIfAbsent(key, () => []);
      if (!formIndex[key]!.contains(form)) {
        formIndex[key]!.add(form);
      }
    }

    if (participle.isEmpty) {
      if (verb.endsWith('ar')) {
        participle = '${verb.substring(0, verb.length - 2)}ado';
      } else if (verb.endsWith('er') || verb.endsWith('ir')) {
        participle = '${verb.substring(0, verb.length - 2)}ido';
      }
    }

    if (gerund.isEmpty) {
      if (verb.endsWith('ar')) {
        gerund = '${verb.substring(0, verb.length - 2)}ando';
      } else if (verb.endsWith('er') || verb.endsWith('ir')) {
        gerund = '${verb.substring(0, verb.length - 2)}iendo';
      }
    }

    final infinitiveCompound = participle.isNotEmpty ? 'haber $participle' : '';
    final gerundCompound = participle.isNotEmpty ? 'habiendo $participle' : '';

    // ── Helper para obtener formas simples con voseo y variantes -ra/-se ──
    String getSimple(String mood, String tense, String person, String number, {bool isSecondPersonSingular = false}) {
      if (isSecondPersonSingular) {
        final std = formIndex['$mood|$tense|second|singular|standard'] ?? [];
        final vos = formIndex['$mood|$tense|second|singular|voseo'] ?? [];
        if (std.isNotEmpty && vos.isNotEmpty && std.join('/') != vos.join('/')) {
          return '${std.join(" / ")} / ${vos.join(" / ")}';
        } else if (std.isNotEmpty) {
          return std.join(' / ');
        } else if (vos.isNotEmpty) {
          return vos.join(' / ');
        }
        return '';
      }

      if (mood == 'subjunctive' && tense == 'imperfecto') {
        final raList = formIndex['$mood|$tense|$person|$number|ra'] ?? [];
        final seList = formIndex['$mood|$tense|$person|$number|se'] ?? [];
        if (raList.isNotEmpty && seList.isNotEmpty) {
          return '${raList.join(" / ")} o ${seList.join(" / ")}';
        } else if (raList.isNotEmpty) {
          return raList.join(' / ');
        } else if (seList.isNotEmpty) {
          return seList.join(' / ');
        }
      }

      final std = formIndex['$mood|$tense|$person|$number|standard'] ??
          formIndex['$mood|$tense|$person|$number|ra'] ??
          formIndex['$mood|$tense|$person|$number|se'] ??
          [];
      return std.join(' / ');
    }

    // ── Formas del auxiliar haber ──
    const haberPres = {'first_s': 'he', 'second_s': 'has', 'third_s': 'ha', 'first_p': 'hemos', 'second_p': 'habéis', 'third_p': 'han'};
    const haberImp = {'first_s': 'había', 'second_s': 'habías', 'third_s': 'había', 'first_p': 'habíamos', 'second_p': 'habíais', 'third_p': 'habían'};
    const haberPret = {'first_s': 'hube', 'second_s': 'hubiste', 'third_s': 'hubo', 'first_p': 'hubimos', 'second_p': 'hubisteis', 'third_p': 'hubieron'};
    const haberFut = {'first_s': 'habré', 'second_s': 'habrás', 'third_s': 'habrá', 'first_p': 'habremos', 'second_p': 'habréis', 'third_p': 'habrán'};
    const haberCond = {'first_s': 'habría', 'second_s': 'habrías', 'third_s': 'habría', 'first_p': 'habríamos', 'second_p': 'habríais', 'third_p': 'habrían'};
    const haberSubjPres = {'first_s': 'haya', 'second_s': 'hayas', 'third_s': 'haya', 'first_p': 'hayamos', 'second_p': 'hayáis', 'third_p': 'hayan'};
    const haberSubjImp = {'first_s': 'hubiera o hubiese', 'second_s': 'hubieras o hubieses', 'third_s': 'hubiera o hubiese', 'first_p': 'hubiéramos o hubiésemos', 'second_p': 'hubierais o hubieseis', 'third_p': 'hubieran o hubiesen'};
    const haberSubjFut = {'first_s': 'hubiere', 'second_s': 'hubieres', 'third_s': 'hubiere', 'first_p': 'hubiéremos', 'second_p': 'hubiereis', 'third_p': 'hubieren'};

    final personDefs = [
      ('yo', 'first', 'singular', 'first_s', false),
      ('tú / vos', 'second', 'singular', 'second_s', true),
      ('usted', 'third', 'singular', 'third_s', false),
      ('él, ella', 'third', 'singular', 'third_s', false),
      ('nosotros, nosotras', 'first', 'plural', 'first_p', false),
      ('vosotros, vosotras', 'second', 'plural', 'second_p', false),
      ('ustedes', 'third', 'plural', 'third_p', false),
      ('ellos, ellas', 'third', 'plural', 'third_p', false),
    ];

    List<ConjugationRowItem> buildRows(String mood, String tense, Map<String, String> haberMap) {
      return personDefs.map((p) {
        final simple = getSimple(mood, tense, p.$2, p.$3, isSecondPersonSingular: p.$5);
        final compound = participle.isNotEmpty ? '${haberMap[p.$4]} $participle' : '';
        return ConjugationRowItem(pronoun: p.$1, simple: simple, compound: compound);
      }).toList();
    }

    // ── 1. Indicativo ──
    final indicativeBlocks = [
      ConjugationTenseBlock(
        simpleTitle: 'Presente',
        compoundTitle: 'Pretérito perfecto compuesto / Antepresente',
        rows: buildRows('indicative', 'presente', haberPres),
      ),
      ConjugationTenseBlock(
        simpleTitle: 'Pretérito imperfecto / Copretérito',
        compoundTitle: 'Pretérito pluscuamperfecto / Antecopretérito',
        rows: buildRows('indicative', 'imperfecto', haberImp),
      ),
      ConjugationTenseBlock(
        simpleTitle: 'Pretérito perfecto simple / Pretérito',
        compoundTitle: 'Pretérito anterior / Antepretérito',
        rows: buildRows('indicative', 'preterito', haberPret),
      ),
      ConjugationTenseBlock(
        simpleTitle: 'Futuro simple / Futuro',
        compoundTitle: 'Futuro compuesto / Antefuturo',
        rows: buildRows('indicative', 'futuro', haberFut),
      ),
      ConjugationTenseBlock(
        simpleTitle: 'Condicional simple / Pospretérito',
        compoundTitle: 'Condicional compuesto / Antepospretérito',
        rows: buildRows('indicative', 'condicional', haberCond),
      ),
    ];

    // ── 2. Subjuntivo ──
    final subjunctiveBlocks = [
      ConjugationTenseBlock(
        simpleTitle: 'Presente',
        compoundTitle: 'Pretérito perfecto compuesto / Antepresente',
        rows: buildRows('subjunctive', 'presente', haberSubjPres),
      ),
      ConjugationTenseBlock(
        simpleTitle: 'Pretérito imperfecto / Pretérito',
        compoundTitle: 'Pretérito pluscuamperfecto / Antepretérito',
        rows: buildRows('subjunctive', 'imperfecto', haberSubjImp),
      ),
      ConjugationTenseBlock(
        simpleTitle: 'Futuro simple / Futuro',
        compoundTitle: 'Futuro compuesto / Antefuturo',
        rows: buildRows('subjunctive', 'futuro', haberSubjFut),
      ),
    ];

    // ── 3. Imperativo ──
    final imperativeDefs = [
      ('tú / vos', 'second', 'singular', true),
      ('usted', 'third', 'singular', false),
      ('vosotros, vosotras', 'second', 'plural', false),
      ('ustedes', 'third', 'plural', false),
    ];

    final imperativeRows = imperativeDefs.map((p) {
      final form = getSimple('imperative', 'presente', p.$2, p.$3, isSecondPersonSingular: p.$4);
      return ConjugationRowItem(pronoun: p.$1, simple: form);
    }).toList();

    return VerbConjugation(
      palabraId: palabraId,
      verb: verb,
      infinitive: infinitive,
      infinitiveCompound: infinitiveCompound,
      gerund: gerund,
      gerundCompound: gerundCompound,
      participle: participle,
      indicativeBlocks: indicativeBlocks,
      subjunctiveBlocks: subjunctiveBlocks,
      imperativeRows: imperativeRows,
    );
  }
}
