import 'dart:convert';

/// Abreviaturas estándar de categorías gramaticales estilo RAE.
String abbreviatePos(String pos) {
  final p = pos.toLowerCase().trim();
  if (p == 'loc. verb.' || p == 'locución verbal') return 'loc. verb.';
  if (p == 'loc. adv.' || p == 'locución adverbial') return 'loc. adv.';
  if (p == 'loc. adj.' || p == 'locución adjetival' || p == 'locución adjetiva') return 'loc. adj.';
  if (p == 'loc. sust.' || p == 'locución sustantiva') return 'loc. sust.';
  if (p == 'loc. prep.' || p == 'locución preposicional' || p == 'locución prepositiva') return 'loc. prep.';
  if (p == 'loc. conj.' || p == 'locución conjuntiva') return 'loc. conj.';
  if (p == 'loc. interj.' || p == 'locución interjectiva') return 'loc. interj.';
  if (p == 'loc. pron.' || p == 'locución pronominal') return 'loc. pron.';
  if (p == 'refrán' || p == 'proverbio') return 'refrán';
  if (p == 'adjetivo' || p == 'adj') return 'adj.';
  if (p == 'sustantivo' || p == 'noun') return 'sust.';
  if (p == 'sustantivo masculino' || p == 'masculine') return 'm.';
  if (p == 'sustantivo femenino' || p == 'feminine') return 'f.';
  if (p == 'verbo' || p == 'verb') return 'v.';
  if (p == 'adverbio' || p == 'adv') return 'adv.';
  if (p == 'pronombre' || p == 'pron') return 'pron.';
  if (p == 'preposición' || p == 'prep') return 'prep.';
  if (p == 'conjunción' || p == 'conj') return 'conj.';
  if (p == 'interjección' || p == 'interj') return 'interj.';
  if (p == 'locución' || p == 'loc') return 'loc.';
  return p.isNotEmpty ? (p.endsWith('.') ? p : '$p.') : '';
}

/// Traducciones editoriales de etiquetas de Wikcionario al español estándar.
const Map<String, String> tagTranslations = {
  // Registros, estilos y usos
  'outdated': 'Desusado',
  'dated': 'Anticuado',
  'archaic': 'Arcaico',
  'obsolete': 'Obsoleto',
  'literary': 'Literario',
  'poetic': 'Poético',
  'colloquial': 'Coloquial',
  'informal': 'Informal',
  'formal': 'Culto',
  'slang': 'Jerga',
  'vulgar': 'Vulgar',
  'pejorative': 'Peyorativo',
  'derogatory': 'Despectivo',
  'offensive': 'Ofensivo',
  'humorous': 'Humorístico',
  'ironic': 'Irónico',
  'figurative': 'Figurado',
  'rare': 'Poco frecuente',
  'uncommon': 'Poco común',
  'neologism': 'Neologismo',
  'historical': 'Histórico',
  'euphemistic': 'Eufemístico',
  'broadly': 'En sentido amplio',
  'narrowly': 'En sentido estricto',
  'strictly': 'En sentido estricto',
  'childish': 'Infantil',
  'jocular': 'Jocoso',
  'taboo': 'Tabú',
  'repeated': 'Frecuente',

  // Gramática y técnica
  'transitive': 'Transitivo',
  'intransitive': 'Intransitivo',
  'reflexive': 'Reflexivo',
  'pronominal': 'Pronominal',
  'adjective': 'Adjetivo',
  'noun': 'Sustantivo',
  'verb': 'Verbo',
  'adverb': 'Adverbio',
  'masculine': 'Masculino',
  'feminine': 'Femenino',
  'singular': 'Singular',
  'plural': 'Plural',

  // Abreviaturas técnicas de plantillas de Wikcionario
  'umrep': 'Frecuente',
  'utsf': 'Figurado',
  'umef': 'Enfático',
  'utci': 'Intransitivo',
  'utcj': 'Interjección',
  'utep': 'Peyorativo',
  'umci': 'Interjección',
  'umcf': 'Figurado',
  'utef': 'Enfático',
  'utsd': 'Despectivo',
  'umcm': 'Coloquial',
  'umct': 'Transitivo',
  'umca': 'Adjetivo',
  'utea': 'Afectivo',
  'utcs': 'Sustantivo',
  'utcp': 'Pronominal',
  'utcr': 'Reflexivo',
  'utpl': 'En plural',
  'rur': 'Rural',
  'vesre': 'Vesre',

  // Regiones y países
  'spain': 'España',
  'mexico': 'México',
  'chile': 'Chile',
  'argentina': 'Argentina',
  'colombia': 'Colombia',
  'peru': 'Perú',
  'venezuela': 'Venezuela',
  'uruguay': 'Uruguay',
  'paraguay': 'Paraguay',
  'bolivia': 'Bolivia',
  'ecuador': 'Ecuador',
  'guatemala': 'Guatemala',
  'cuba': 'Cuba',
  'el-salvador': 'El Salvador',
  'honduras': 'Honduras',
  'nicaragua': 'Nicaragua',
  'panama': 'Panamá',
  'río-de-la-plata': 'Río de la Plata',
  'rio-de-la-plata': 'Río de la Plata',
  'puerto-rico': 'Puerto Rico',
  'costa-rica': 'Costa Rica',
  'dominican-republic': 'República Dominicana',
  'central-america': 'América Central',
  'south-america': 'América del Sur',
  'south-cone': 'Cono Sur',
  'southern-chile': 'Sur de Chile',
  'northern-chile': 'Norte de Chile',
  'central-chile': 'Chile Central',
  'northern-argentina': 'Norte de Argentina',
  'equatorial-guinea': 'Guinea Ecuatorial',
  'mexico-city': 'Ciudad de México',
  'lower-california': 'Baja California',
  'new-mexico': 'Nuevo México',
  'balearic-islands': 'Islas Baleares',
  'basque country': 'País Vasco',
  'castile': 'Castilla',
  'catalonia': 'Cataluña',
  'nuevo-león': 'Nuevo León',
  'san-luis-potosí': 'San Luis Potosí',
  'ribera-navarra': 'Ribera Navarra',

  // Fórmulas de uso y registro (Estilo RAE)
  'se usa también como sustantivo': 'U. t. c. s.',
  'se usa también como sustantivo.': 'U. t. c. s.',
  'usado también como sustantivo': 'U. t. c. s.',
  'se emplea también como sustantivo': 'U. t. c. s.',
  'sustantivado': 'U. t. c. s.',

  'se usa también como adjetivo': 'U. t. c. adj.',
  'se usa también como adjetivo.': 'U. t. c. adj.',
  'usado también como adjetivo': 'U. t. c. adj.',
  'se emplea también como adjetivo': 'U. t. c. adj.',

  'se usa también como pronominal': 'U. t. c. prnl.',
  'se usa también como pronominal.': 'U. t. c. prnl.',
  'usado también como pronominal': 'U. t. c. prnl.',
  'se emplea también como pronominal': 'U. t. c. prnl.',

  'se usa también como transitivo': 'U. t. c. tr.',
  'usado también como transitivo': 'U. t. c. tr.',
  'se emplea también como transitivo': 'U. t. c. tr.',

  'se usa también como intransitivo': 'U. t. c. intr.',
  'usado también como intransitivo': 'U. t. c. intr.',
  'se emplea también como intransitivo': 'U. t. c. intr.',

  'se usa también como interjección': 'U. t. c. interj.',
  'usado también como interjección': 'U. t. c. interj.',
  'se emplea también como interjección': 'U. t. c. interj.',

  'se usa más en plural': 'U. m. en pl.',
  'se usa más en plural.': 'U. m. en pl.',
  'se usa mayormente en plural': 'U. m. en pl.',
  'se emplea más en plural': 'U. m. en pl.',
  'se emplea también en plural': 'U. t. en pl.',
  'se usa principalmente en plural': 'U. m. en pl.',
  'en plural': 'U. m. en pl.',
  'en masculino': 'U. m. en m.',
  'en femenino': 'U. m. en f.',

  'caribbean': 'Caribe',
  'united states': 'Estados Unidos',
  'latin america': 'América Latina',
  'lower case': 'Minúscula',
  'upper case': 'Mayúscula',
};

/// Metatags de plantillas que no deben renderizarse como etiquetas visibles.
const Set<String> ignoredTags = {
  'form-of',
  'form of',
  'table-tags',
  'inflection-template',
  'entry-template',
  'error-unknown-tag',
  'wiki',
  'template',
  'canonical',
};

/// Parsea y traduce las etiquetas crudas a términos editoriales legibles.
List<String> parseTags(dynamic rawTagsVal) {
  if (rawTagsVal == null) return [];
  List<String> list = [];
  if (rawTagsVal is String) {
    final s = rawTagsVal.trim();
    if (s.startsWith('[') && s.endsWith(']')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) {
          list = decoded.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
        }
      } catch (_) {
        list = s
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .replaceAll("'", '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else {
      list = s.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
  } else if (rawTagsVal is List) {
    list = rawTagsVal.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
  }

  final filtered = list.where((t) {
    final low = t.toLowerCase().trim();
    return !ignoredTags.contains(low) && !ignoredTags.contains(low.replaceAll('-', ' '));
  });

  return filtered.map((t) {
    final low = t.toLowerCase().trim();
    if (tagTranslations.containsKey(low)) {
      return tagTranslations[low]!;
    }
    final clean = t.replaceAll('-', ' ').trim();
    return clean.isNotEmpty ? clean[0].toUpperCase() + clean.substring(1) : clean;
  }).toList();
}

/// Formatea el lema principal agregando la desinencia femenina (estilo RAE: "bueno, na").
String formatDisplayLemma(String word, List<String> posLabels) {
  final wLow = word.toLowerCase();
  final isAdjectiveOrNoun = posLabels.any((l) =>
      l.toLowerCase().contains('adjetivo') || l.toLowerCase().contains('sustantivo'));

  if (wLow.endsWith('o') && wLow.length > 3 && isAdjectiveOrNoun) {
    if (wLow.endsWith('so')) return '$word, sa';
    if (wLow.endsWith('do')) return '$word, da';
    if (wLow.endsWith('to')) return '$word, ta';
    if (wLow.endsWith('co')) return '$word, ca';
    if (wLow.endsWith('go')) return '$word, ga';
    if (wLow.endsWith('jo')) return '$word, ja';
    if (wLow.endsWith('no')) return '$word, na';
    if (wLow.endsWith('ro')) return '$word, ra';
    if (wLow.endsWith('vo')) return '$word, va';
    if (wLow.endsWith('lo')) return '$word, la';
  }
  return word;
}
