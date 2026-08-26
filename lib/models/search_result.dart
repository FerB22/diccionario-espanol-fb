/// Resultado liviano de búsqueda (evita cargar el objeto Word completo).
class SearchResult {
  final int id;
  final String word;
  final String pos;
  final String posLabel;

  const SearchResult({
    required this.id,
    required this.word,
    required this.pos,
    required this.posLabel,
  });

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      id:       map['id']        as int,
      word:     (map['word']     as String?) ?? '',
      pos:      (map['pos']      as String?) ?? '',
      posLabel: (map['pos_label'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id':        id,
    'word':      word,
    'pos':       pos,
    'pos_label': posLabel,
  };

  @override
  String toString() => 'SearchResult(id: $id, word: $word)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SearchResult && other.id == id);

  @override
  int get hashCode => id.hashCode;
}