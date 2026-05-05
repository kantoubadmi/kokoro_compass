class HappinessRecord {
  final int? id;
  final int score;
  final String? note;
  final DateTime createdAt;

  HappinessRecord({
    this.id,
    required this.score,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HappinessRecord.fromMap(Map<String, dynamic> map) {
    return HappinessRecord(
      id: map['id'] as int?,
      score: map['score'] as int,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}