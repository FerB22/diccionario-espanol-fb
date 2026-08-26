/// Modelo principal de una palabra / lema del diccionario.
class Word {
  final int id;
  final String word;
  final String wordLower;
  final String pos;
  final String posLabel;
  final String? ipa;

  const Word({
    required this.id,
    required this.word,
    required this.wordLower,
    required this.pos,
    required this.posLabel,
    this.ipa,
  });

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id:        map['id']        as int,
      word:      (map['word']     as String?) ?? '',
      wordLower: (map['word_lower'] as String?) ?? '',
      pos:       (map['pos']      as String?) ?? '',
      posLabel:  (map['pos_label'] as String?) ?? '',
      ipa:        map['ipa']      as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':        id,
    'word':      word,
    'word_lower': wordLower,
    'pos':       pos,
    'pos_label': posLabel,
    'ipa':       ipa,
  };

  @override
  String toString() => 'Word(id: $id, word: $word, pos: $pos)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Word && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Representa una acepción / sentido de una palabra.
class Sense {
  final int id;
  final int palabraId;
  final int orderNum;
  final String gloss;
  final List<String> rawTags;

  const Sense({
    required this.id,
    required this.palabraId,
    required this.orderNum,
    required this.gloss,
    required this.rawTags,
  });

  factory Sense.fromMap(Map<String, dynamic> map) {
    // rawTags puede venir como String delimitado por '|' o como List
    List<String> parseTags(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      final str = value.toString();
      if (str.isEmpty) return [];
      return str.split('|').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }

    return Sense(
      id:        map['id']        as int,
      palabraId: map['palabra_id'] as int,
      orderNum:  (map['order_num'] as int?) ?? 0,
      gloss:     (map['gloss']    as String?) ?? '',
      rawTags:   parseTags(map['raw_tags']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id':        id,
    'palabra_id': palabraId,
    'order_num': orderNum,
    'gloss':     gloss,
    'raw_tags':  rawTags.join('|'),
  };

  @override
  String toString() => 'Sense(id: $id, gloss: $gloss)';
}