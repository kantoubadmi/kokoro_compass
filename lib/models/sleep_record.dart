class SleepRecord {
  final int? id;
  final int quality; // 1-5 scale
  final int hoursSlept; // hours
  final int minutesSlept; // minutes
  final String? note;
  final DateTime createdAt;

  SleepRecord({
    this.id,
    required this.quality,
    required this.hoursSlept,
    required this.minutesSlept,
    this.note,
    required this.createdAt,
  });

  int get totalMinutes => hoursSlept * 60 + minutesSlept;

  String get durationString {
    if (minutesSlept == 0) {
      return '$hoursSlept時間';
    }
    return '$hoursSlept時間$minutesSlept分';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quality': quality,
      'hours_slept': hoursSlept,
      'minutes_slept': minutesSlept,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'] as int?,
      quality: map['quality'] as int,
      hoursSlept: map['hours_slept'] as int,
      minutesSlept: map['minutes_slept'] as int,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
